<p align="center">
  <img src="http://jwt.io/img/logo-asset.svg" />
</p>

## JSON Web Token Implementation

This is a barebones implementation of [JWT (JSON Web Token)](https://jwt.io) in V (or vlang, for search engine friendliness). It currently supports only the HMAC-SHA algorithm, support for other algorithms (like RSA and ED25519) is a work in progress. Please feel free to open a issue/pull request if you find any problem or want to add a feature. Take a look at the todos.md file if you just want to contribute, but don't know what to help with.

## Installation

To install JWT, just type in the following (uploading to vpm, vpkg is in progress):

```
git clone https://github.com/gamemaker1/jwt ~/.vmodules/jwt/
```

On Windows (command prompt), replace the `~` above with `%USERPROFILE%`.

## Usage

First, create a header object and specify the algorithm you want to use (default is HMAC with SHA384):

```v
// Create headers with the default algorithm (HMAC with SHA384). Available
// values include .hs224 (HMAC with SHA224), .hs256 (HMAC with SHA256), .hs384
// (HMAC with SHA384) and .hs512 (HMAC with SHA512)
mut headers := jwt.headers(.default)
```

Then declare a struct that contains all the claims you want to put in the token:

```v
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
```

Create an instance of the struct with the values you want to put in:

```v
// The current time (this requires the `time` module to be imported,
// i.e., add `import time` at the top where you import the `jwt` module)
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
```

Then define the secret used to sign the token's headers and claims. If you are using HMAC, you can use a secret_key with sufficient entropy according to the algorithm you use. If you are using RSA, use a private key:

```v
// The secret key used to sign the algorithm (for HMAC). In case you are 
// using RSA, use the private key here instead. It is recommended to read
// this secret from a file. The secret should be known only to the entity
// issuing the JWTs, i.e., an auth server
secret_key := 'YOUR_SUPER_SECRET_KEY'
```

Now create the JWT (remember to specify the struct name in <> while calling `create()`):
```v
// Generate a token. Add the type of custom claim in <> as well to allow json 
// serialization.
token := jwt.create<CustomClaims>(headers, claims, secret_key) or {
	// Handle errors in the `or` block. To let the program panic on an error, 
	// or to return the error to the calling function, replace this entire `or` 
	// block with a `?`
	println('An error occurred - $err')
	return
}
```

To decode and verify the signature of the token, use the `decode()` method - it will return the headers and the claims of the token if the signature is valid:

```v
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
```

## Example

For an example program that uses `jwt`, take a look at [`jwt_example.v`](./jwt_example.v).

## Todos

Refer to [the todos file](./todos.md).

## Legal stuff

### License: ISC

Copyright (c) 2021, Vedant K (gamemaker1) \<gamemaker0042@gmail.com\>

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
