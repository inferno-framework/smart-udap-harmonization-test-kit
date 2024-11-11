# Inferno UDAP Security IG Test Kit 

The [Security for Scalable Registration, Authentication, and Authorization
IG](https://hl7.org/fhir/us/udap-security/index.html) states that

> This guide is also intended to be compatible and harmonious with client and
> server use of versions 1 or 2 of the HL7 SMART App Launch IG.

This test kit is an effort to demonstrate how a client could interact with a
server supporting both UDAP and SMART App Launch.

## Overview
The basic assumption underlying these tests is that a client could perform
dynamic registration and launch with client authorization from the UDAP workflow
while using SMART App Launch scopes, and the server could include additional
launch context parameters defined by SMART App Launch in the token response.

The tests begin with normal parts of the UDAP workflow: discovery, dynamic
registration, and authorization.

Then there are tests for SMART App Launch context parameters which could be
included as part of the token response, including an OpenIDConnect id token.
Finally, there are tests for token refresh.

## Known Limitations
The UDAP dynamic registration workflow does not define a way to register a
launch URI, so the tests only perform a standalone launch.

## Instructions

- Clone this repo.
- Run `setup.sh` in this repo
- Run `run.sh` in this repo.
- Navigate to `http://localhost`. The SMART-UDAP Harmonization test suite will
  be available.
- Prior to running Dynamic Client Registration tests or Authorization tests, the
  authorization server under test MUST be configured to trust the signing
  certificate that issues and signs the client certificates. See the following
  section for more details. 

### Certificate Setup for Running Tests

Running UDAP Dynamic Client Registration and Authorization tests requires the
use of X.509 certificates that are trusted by the authorization server under
test.  There are two categories of certificates for this test kit:
- Client certificates: represent the logical instance of a UDAP client interfacing
  with the authorization server.  This test
  kit supports multiple logical clients, and a new logical client is needed for each instance of
  testing Dynamic Client Registration. 
- Signing certificate: the certificate used to issue and sign the client
  certificates.

Testers must provide their own client certificate(s) via the
test inputs.  Currently, the certificates available in `lib/udap_security_test_kit/certs`
are for unit testing only.

In order for tests to pass, register your own signing certificate as a trust anchor with
the authorization server under tests. 


## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
