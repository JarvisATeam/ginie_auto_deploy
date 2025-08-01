#!/usr/bin/env python3

"""
generate_qr.py – QR generation, snapshot packaging and vault encryption

This script automates the final steps of preparing the GinieSystem for
deployment. It performs the following tasks:

1. Constructs the installation command and encodes it in a QR code.
2. Packages the current repository into a ZIP archive.
3. Computes a SHA‑256 hash of the archive for integrity verification.
4. Encrypts the archive using Fernet symmetric encryption and writes
   out the encrypted file and key for later decryption.

Run this script from the root of the repository:

  $ python3 generate_qr.py
"""

import os
import hashlib
import zipfile
import json
from datetime import datetime
import subprocess


def build_install_command() -> str:
    """Return the shell command that installs GinieSystem via curl/bash."""
    # Replace the URL with the final repository location once pushed to GitHub
    repo_url = os.environ.get("REPO_URL", "https://github.com/your-github-username/ginie_auto_deploy.git")
    return f"/bin/bash -c \"$(curl -fsSL {repo_url}/raw/main/install.sh)\""


def generate_qr(command: str, out_path: str) -> None:
    """Generate a QR code image for the given command using an external API.

    The function calls the public API `api.qrserver.com` to create a QR code
    representing the installation command. It downloads the image via curl
    and writes it to `out_path`. If the API call fails, the function
    raises a `RuntimeError`.
    """
    import urllib.parse
    url = f"https://api.qrserver.com/v1/create-qr-code/?size=300x300&data={urllib.parse.quote(command)}"
    try:
        subprocess.run(["curl", "-fL", "-o", out_path, url], check=True)
    except Exception as e:
        raise RuntimeError(f"Failed to download QR code: {e}")


def create_snapshot(zip_path: str) -> None:
    """Package the repository into a ZIP archive at zip_path."""
    repo_root = os.path.dirname(os.path.realpath(__file__))
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(repo_root):
            for name in files:
                # Skip existing snapshots or keys to avoid recursion
                if name.endswith(('.zip', '.enc', '.key', '.png', '.sha256')):
                    continue
                file_path = os.path.join(root, name)
                arcname = os.path.relpath(file_path, repo_root)
                zf.write(file_path, arcname)


def compute_hash(file_path: str) -> str:
    """Compute SHA‑256 hash of the specified file and return hex digest."""
    sha256 = hashlib.sha256()
    with open(file_path, 'rb') as f:
        for chunk in iter(lambda: f.read(8192), b''):
            sha256.update(chunk)
    return sha256.hexdigest()


def encrypt_file(input_path: str, enc_path: str, key_path: str) -> None:
    """Encrypt the input file using OpenSSL AES‑256‑CBC.

    Generates a random 32‑byte key (hex encoded) and uses it as the
    passphrase for OpenSSL symmetric encryption. Writes the encrypted
    archive and key file. The key file contains the passphrase used by
    OpenSSL.
    """
    import secrets
    # Generate a random 64‑character hexadecimal password (256 bits)
    password = secrets.token_hex(32)
    # Use openssl to encrypt
    subprocess.run([
        "openssl", "enc", "-aes-256-cbc", "-salt",
        "-pbkdf2", "-pass", f"pass:{password}",
        "-in", input_path, "-out", enc_path
    ], check=True)
    # Write key to file
    with open(key_path, 'w') as f:
        f.write(password)


def main() -> None:
    output_dir = os.path.dirname(os.path.realpath(__file__))
    timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
    cmd = build_install_command()

    # 1. Generate QR code (best effort)
    qr_path = os.path.join(output_dir, f'install_qr_{timestamp}.png')
    try:
        generate_qr(cmd, qr_path)
        print(f"Generated QR code: {qr_path}")
    except Exception as e:
        # If QR generation fails (e.g. due to network restrictions), continue.
        print(f"Warning: QR generation failed ({e}). Continuing without QR file.")
        qr_path = None

    # 2. Create snapshot ZIP
    zip_path = os.path.join(output_dir, f'snapshot_{timestamp}.zip')
    create_snapshot(zip_path)
    print(f"Created snapshot: {zip_path}")

    # 3. Compute SHA‑256 hash
    sha256 = compute_hash(zip_path)
    sha_path = f"{zip_path}.sha256"
    with open(sha_path, 'w') as f:
        f.write(f"{sha256}  {os.path.basename(zip_path)}\n")
    print(f"Computed SHA‑256: {sha256}")

    # 4. Encrypt snapshot
    enc_path = f"{zip_path}.enc"
    key_path = f"{zip_path}.key"
    encrypt_file(zip_path, enc_path, key_path)
    print(f"Encrypted snapshot: {enc_path}")
    print(f"Encryption key saved to: {key_path}")

    # 5. Summary JSON
    summary = {
        'install_command': cmd,
        'qr_code': os.path.basename(qr_path) if qr_path else None,
        'snapshot': os.path.basename(zip_path),
        'sha256': sha256,
        'encrypted_snapshot': os.path.basename(enc_path),
        'key_file': os.path.basename(key_path)
    }
    json_path = os.path.join(output_dir, f'build_summary_{timestamp}.json')
    with open(json_path, 'w') as f:
        json.dump(summary, f, indent=2)
    print(f"Build summary saved to: {json_path}")


if __name__ == '__main__':
    main()