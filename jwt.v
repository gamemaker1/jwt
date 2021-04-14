// JWT - the namespace for this library/module
module jwt

// Imports: use `base64` to encode the headers and claim and `json` to parse
// them
import encoding.base64
import json

// Valid algorithms for signing the headers and claims
enum Algorithm {
	hs224
	hs256
	hs384
	hs512
	default
}

// Get the specification-given name for an algorithm from the enum
pub fn (algorithm Algorithm) get_name() string {
	return match algorithm {
		.hs224 { 'HS224' }
		.hs256 { 'HS256' }
		.default, .hs384 { 'HS384' }
		.hs512 { 'HS512' }
	}
}

// The headers that can be put into a token
pub struct Headers {
	pub:
		// The algorithm used to sign the token (cannot be changed once initialised)
		alg string = 'HS384'
	pub mut:
		// The type of token - this can be made application specific
		typ string = 'jwt'
		// The ID of the key used to sign the token
		kid string
}

// Return an instance of the Header struct with a certain algorithm
pub fn headers(algorithm Algorithm) Headers {
	return Headers { alg: algorithm.get_name() }
}

// Sign the given claims and headers using the algorithm specified in the
// headers. The claims can be any custom struct, provided the struct contains
// serializable fields only.
pub fn create<T>(headers Headers, claims T, secret_key string) ?string {
	// base64 encode the headers and claims
	encoded_headers := base64.url_encode(
		json.encode(headers).bytes()
	).replace('=', '')
	encoded_claims := base64.url_encode(
		json.encode(claims).bytes()
	).replace('=', '')

	// Sign the headers and claims using the specified algorithm
	signature := base64.url_encode(
		sign_jwt(headers.alg, encoded_headers, encoded_claims, secret_key)?
	).replace('=', '')

	// Return the headers, claims and signature joined by '.'s
	return (
		encoded_headers
			+ '.'
			+ encoded_claims
			+ '.'
			+ signature
	)
}

// Decode the given JWT and verify the signature using the specified algorithm.
// If the signature is correct, then return the headers as an instance of the
// Headers struct and the claims as an instance of a custom struct the caller
// passes
pub fn decode<T>(
	jwt string,
	algorithm Algorithm,
	secret_key string
) ?(Headers, T) {
	// Split the JWT into three parts - header, claims and signature
	split_jwt := jwt.split('.')
	// Check that the JWT is made up of only three parts.
	if split_jwt.len != 3 {
		return error(
			'Improperly formatted JWT! Note: encrypted JWTs are not yet supported.'
		)
	}

	// Get the headers, claims and signature
	mut jwt_headers := split_jwt[0]
	mut jwt_claims := split_jwt[1]
	mut jwt_signature := split_jwt[2]
	// Pad the base64 encoded strings with '='s (we strip the padding when
	// generating the token)
	jwt_headers = pad_base64(jwt_headers)
	jwt_claims = pad_base64(jwt_claims)
	jwt_signature = pad_base64(jwt_signature)

	// Decode the headers (first from base64, then to an instance of the Headers
	// struct)
	decoded_headers := base64.decode_str(jwt_headers)
	headers := json.decode(Headers, decoded_headers)?
	// Decode the claims (first from base64, then to an instance of the provided
	// custom claims struct)
	decoded_claims := base64.decode_str(jwt_claims)
	claims := json.decode(T, decoded_claims)?

	// Check that the algorithm given in the JWT is the same as the one we were
	// given to verify the token.
	if headers.alg != algorithm.get_name() {
		return error(
			'Algorithm specified in JWT header (${headers.alg}) differs from specified algorithm ${algorithm}.'
		)
	}

	// Sign the headers and claims again and check that it is the same as the
	// signature in the JWT.
	new_signature := base64.url_encode(
		sign_jwt(headers.alg, split_jwt[0], split_jwt[1], secret_key)?
	).replace('=', '')
	if new_signature != split_jwt[2] {
		return error('Invalid JWT signature')
	}

	// Once the signature is validated, return the headers and the claims
	return headers, claims
}

// Sign a JWT with the specified algorithm. This uses functions part of the jwt
// module, in the hmac.v file(s)
fn sign_jwt(
	algorithm string,
	encoded_headers string,
	encoded_claims string,
	secret_key string
) ?[]byte {
	match algorithm {
		'HS224' { return hmac224(encoded_headers, encoded_claims, secret_key) }
		'HS256' { return hmac256(encoded_headers, encoded_claims, secret_key) }
		'HS384' { return hmac384(encoded_headers, encoded_claims, secret_key) }
		'HS512' { return hmac512(encoded_headers, encoded_claims, secret_key) }
		else { return error('Invalid algorithm specified') }
	}
}

// Pad a base64 string with '='s if required
fn pad_base64(encoded_str string) string {
	mut padded_str := encoded_str
	// The string should be divisible into blocks of 4. If the last block is not
	// 4 characters long, then add '='s until it becomes 4 characters long
	if padded_str.len % 4 != 0 {
		for _ in 0..(padded_str.len % 4) {
			padded_str += '='
		}
	}

	return padded_str
}
