// Simply copying-pasting the contents of this file into a `.v` file on your 
// machine and running it on your computer with `v run <file-name>.v will work -
// simply ensure the `jwt` module is installed.

// EXAMPLE PROGRAM USING THE JWT MODULE

// Import the module
import gamemaker1.jwt
// Import the time module
import time

// A struct declaring custom claims to be encoded in the JWT (these are
// all example values, replace them with your own. You might want to look
// at https://en.wikipedia.org/wiki/JSON_Web_Token#Standard_fields for a
// list of standard fields used in a JWT)
struct CustomClaims {
	// The user name
	user_name string
	// The user ID
	user_id string
	// The `iat`, or Issued At Time as an epoch timestamp
	iat u64
	// The `exp` or Expires At Time (Here we set it to expire after one 
	// hour) as an epoch timestamp
	exp u64
}

// The main function, entrypoint of the program
fn main() {
	// Create headers with the default algorithm (HMAC with SHA384). Available 
	// values include hs224 (HMAC with SHA224), hs256 (HMAC with SHA256), hs384 
	// (HMAC with SHA384) and hs512 (HMAC with SHA512)
	mut headers := jwt.headers(.default)

	// The current time
	current_time := time.utc()
	// Create the claims to put in the JWT
	claims := CustomClaims {
		// The user name
		'exampleusername',
		// The user ID
		'sISDkdmeIEpwS9W',
		// The `iat`, or Issued At Time as an epoch timestamp
		current_time.unix,
		// The `exp` or Expires At Time (Here we set it to expire after one 
		// hour) as an epoch timestamp
		current_time.add_seconds(3600).unix
	}

	// The secret key used to sign the algorithm (for HMAC). In case you are 
	// using RSA, use the private key here instead. It is recommended to read
	// this secret from a file. The secret should be known only to the entity
	// issuing the JWTs, i.e., an auth server
	secret_key := 'YOUR_SUPER_SECRET_KEY'

	// Generate a token. Add the type of custom claim in <> as well to allow json 
	// serialization.
	token := jwt.create<CustomClaims>(headers, claims, secret_key) or {
		// Handle errors in the `or` block. To let the program panic on an error, 
		// or to return the error to the calling function, replace this entire `or` 
		// block with a `?`
		println('An error occurred - $err')
		return
	}

	// Print out the generated token
	println('Generated token: $token')

	// Verify the signature of the generated token and decode it.
	retrieved_headers, retrieved_claims := jwt.decode<CustomClaims>(
		// The JWT
		token,
		// The algorithm that was used to generate the JWT
		.default,
		// The secret key (in case of HMAC) or private key (in case of RSA) used to 
		// sign the JWT
		secret_key
	) or {
		// Handle errors in the `or` block. To let the program panic on an error, 
		// or to return the error to the calling function, replace this entire `or` 
		// block with a `?`
		println('An error occurred - $err')
		return
	}

	// Print out the decoded headers and claims
	println('Decoded and verified JWT.')
	println('Retrieved headers: $retrieved_headers')
	println('Retrieved claims: $retrieved_claims')
}