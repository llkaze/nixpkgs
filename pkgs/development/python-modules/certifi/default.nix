{ lib
, buildPythonPackage
, cacert
, pythonOlder
, fetchFromGitHub
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "certifi";
  version = "2022.09.24";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = pname;
    repo = "python-certifi";
    rev = version;
    hash = "sha256-B6LO6AfG9cfpyNI7hj3VjmGTFsrrIkDYO4gPMkZY74w=";
  };

  patches = [
    # Add support for NIX_SSL_CERT_FILE
    ./env.patch
  ];

  postPatch = ''
    # Use our system-wide ca-bundle instead of the bundled one
    rm -v "certifi/cacert.pem"
    ln -snvf "${cacert}/etc/ssl/certs/ca-bundle.crt" "certifi/cacert.pem"
  '';

  checkInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    # NIX_SSL_CERT_FILE is set to /no-cert-file.crt during build, which
    # breaks the tests
    unset NIX_SSL_CERT_FILE
  '';

  pythonImportsCheck = [
    "certifi"
  ];

  meta = with lib; {
    homepage = "https://github.com/certifi/python-certifi";
    description = "Python package for providing Mozilla's CA Bundle";
    license = licenses.isc;
    maintainers = with maintainers; [ koral SuperSandro2000 ];
  };
}
