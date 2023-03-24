
"""
1. User Create
2. Generate User Password for one time login
  - must create with randomly select 1 number, 1 uppercase, 1 lowercase, and 1 special characters
  - password length is 12-digit
3.Set the user password
  - Create the user account with the generated password and force password change on first login
4.add Google OTP (goole authenticator)
""" 

import subprocess
import random
import string
import sys
import os


class Bcolors:
    Black = '\033[30m'
    Red = '\033[31m'
    Green = '\033[32m'
    Yellow = '\033[33m'
    Blue = '\033[34m'
    Magenta = '\033[35m'
    Cyan = '\033[36m'
    White = '\033[37m'
    Endc = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def check_runlevel():
    if os.geteuid() == 0:
        return True
    else:
        return False


def generate_password():
    # a string containing numbers, uppercase, lowercase, and special characters
    digits = string.digits
    uppercase_letters = string.ascii_uppercase
    lowercase_letters = string.ascii_lowercase
    symbols = string.punctuation

    # randomly select 1 number, uppercase, lowercase, and special characters
    # Store everything else as an 8-digit string
    random_chars = [
        random.choice(digits),
        random.choice(uppercase_letters),
        random.choice(lowercase_letters),
        random.choice(symbols),
    ] + random.choices(
        string.ascii_letters + string.digits + string.punctuation,
        k=8
    )

    # Generate again the random 12-digit string using random_chars
    password = ''.join(random.sample(random_chars, len(random_chars)))

    print(f'- Password Length: {len(password)}')
    print(f'- Password: {password}')
    return password


def add_google_otp(username):
    # Generate a random secret key for Google OTP
    secret_key = ''.join(random.choices(string.ascii_uppercase + string.ascii_lowercase + string.digits, k=16))

    # Add the Google OTP secret key to the user account
    subprocess.run(["sudo", "-u", username, "google-authenticator", "-t", "-d", "-r", "3", "-R", "30", "-f"])

    # Get the Google OTP QR code link for the secret key
    qr_code_link = subprocess.check_output(["sudo", "-u", username, "google-authenticator", "-p", "-", "-f"],
                                           input=secret_key.encode()).decode().strip()

    # Replace otpauth://totp/ with https://www.google.com/chart?
    qr_code_link = qr_code_link.replace('otpauth://totp/', 'https://www.google.com/chart?chs=200x200&chld=M%7C0&cht=qr&')
    return secret_key, qr_code_link


def user_create(username):
    # Create the user account with the generated password and force password change on first login
    passwd = generate_password()
    subprocess.run(["sudo", "useradd", "--create-home", username, "--shell", "/bin/bash"])
    subprocess.run(["sudo", "echo", f"{username}:{passwd}", "|", "chpasswd"])
    subprocess.run(["sudo", "chage", "-d", "0", username])

    # Add Google OTP to the user account
    secret_key, qr_code_link = add_google_otp(username)

    print(f'- User account {username} created successfully with password {passwd} and Google OTP configured.')

    print(f'- Google OTP Secret Key: {secret_key}')
    print(f'- Google OTP QR Code Link: {qr_code_link}')


def main():
    is_root = check_runlevel()

    if is_root:
        user_create('john_conner')
    else:
        print(f'{Bcolors.Yellow}- Error: Please run with root privileges. {Bcolors.Endc}')
        sys.exit(1)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
    except Exception as e:
        print(f'{Bcolors.Yellow}- ::Exception:: Func:[{__name__.__name__}] '
              f'Line:[{sys.exc_info()[-1].tb_lineno}] [{type(e).__name__}] {e}{Bcolors.Endc}')
