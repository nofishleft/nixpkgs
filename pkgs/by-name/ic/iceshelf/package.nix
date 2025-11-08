{
  lib,
  fetchFromGitHub,
  git,
  awscli,
  par2cmdline,
  python3,
  sshpass,
  openssh,
}:

python3.pkgs.buildPythonApplication {
  pname = "iceshelf";
  version = "0-unstable-2025-11-08";

  format = "other";

  src = fetchFromGitHub {
    owner = "nofishleft";
    repo = "iceshelf";
    rev = "8db51eb7a0f0e2ae6f6984309b639ae308c74df4";
    sha256 = "+IADaY6RyV0fPxBWyUz0nuFif0BwrJdDdq6UXWfEhok=";
  };

  postPatch = ''
    substituteInPlace iceshelf --replace-fail "Popen(['git'" "Popen(['${git}/bin/git'"
    substituteInPlace modules/fileutils.py --replace-fail "cmd = [\"par2\"" "cmd = ['${par2cmdline}/bin/par2'"
    substituteInPlace modules/configuration.py --replace-fail "which(\"par2\")" "which('${par2cmdline}/bin/par2')"
    substituteInPlace modules/providers/sftp.py \
      --replace-fail "base += ['sshpass'" "base += ['${sshpass}/bin/sshpass'" \
      --replace-fail "sftp_cmd = ['sftp'" "sftp_cmd = ['${openssh}/bin/sftp'" \
      --replace-fail "_which('sshpass')" "_which('${sshpass}/bin/sshpass')" \
      --replace-fail "_which('sftp')" "_which('${openssh}/bin/sftp')"
    substituteInPlace modules/providers/scp.py \
      --replace-fail "base += ['sshpass'" "base += ['${sshpass}/bin/sshpass'" \
      --replace-fail "scp_cmd = ['scp'" "scp_cmd = ['${openssh}/bin/scp'" \
      --replace-fail "_which('sshpass')" "_which('${sshpass}/bin/sshpass')" \
      --replace-fail "_which('scp')" "_which('${openssh}/bin/scp')"
    substituteInPlace modules/providers/s3.py \
      --replace-fail "cmd = ['aws'" "cmd = ['${awscli}/bin/aws'" \
      --replace-fail "_which('aws')" "_which('${awscli}/bin/aws')"
    substituteInPlace modules/providers/glacier.py --replace-fail "_which('aws')" "_which('${awscli}/bin/aws')"
    substituteInPlace modules/aws.py --replace-fail "cmd = ['aws'" "cmd = ['${awscli}/bin/aws'"
  '';

  propagatedBuildInputs = [
    python3.pkgs.python-gnupg
    python3.pkgs.boto3
  ];

  installPhase = ''
    mkdir -p $out/bin $out/share/doc/iceshelf $out/${python3.sitePackages}
    cp -v iceshelf iceshelf-restore iceshelf-retrieve iceshelf-inspect $out/bin
    cp -v iceshelf.sample.conf $out/share/doc/iceshelf/
    cp -rv modules $out/${python3.sitePackages}
  '';

  meta = with lib; {
    description = "Simple tool to allow storage of signed, encrypted, incremental backups using Amazon's Glacier storage";
    license = licenses.lgpl2;
    homepage = "https://github.com/mrworf/iceshelf";
    maintainers = with maintainers; [ mmahut ];
  };
}
