#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Good Morning, Pineapple."
echo "Looking very good, very nice."

# Function to fetch Jenkins versions
version_fetcher() {
    echo "Fetching Jenkins versions initiated..."
    LTS_VERSION=$(curl -s https://www.jenkins.io/ | grep -oP '(?<=Latest LTS: )[\d\.]+')
    PREVIOUS_VERSION=$(curl -s https://updates.jenkins.io/ | grep -oP '\d+\.\d+\.\d+' | sort -Vr | grep -B1 "$LTS_VERSION" | head -n1)

    if [[ -z "$LTS_VERSION" || -z "$PREVIOUS_VERSION" ]]; then
        echo "Error: Unable to fetch Jenkins versions. Please check your internet connection."
        exit 1
    fi

    echo "Latest LTS Version: $LTS_VERSION"
    echo "Previous Version: $PREVIOUS_VERSION"
}

# Function to prompt user for version selection
version_selector() {
    echo -e "\nWhich Jenkins version do you want to install?"
    echo "1) Latest LTS Version ($LTS_VERSION)"
    echo "2) Previous Version ($PREVIOUS_VERSION)"
    echo "3) Enter a custom version"

    read -p "Enter your choice [1/2/3]: " choice

    case "$choice" in
        1) JENKINS_VERSION="$LTS_VERSION" ;;
        2) JENKINS_VERSION="$PREVIOUS_VERSION" ;;
        3)
            read -p "Enter the Jenkins version you want to install (e.g., 2.46.2): " custom_version
            JENKINS_VERSION="$custom_version"
            ;;
        *)
            echo "Invalid choice. Exiting..."
            exit 1
            ;;
    esac
}

# Function to detect operating system
detect_os() {
    unameOut="$(uname -s)"  # uname data about OS version
                            # -s flag for kernel name only      
    case "${unameOut}" in
        Linux*)     OS=Linux ;;
        Darwin*)    OS=Mac ;;
        CYGWIN*|MINGW*|MSYS*|MINGW32*|MINGW64*) OS=Windows ;;
        *)          OS="UNKNOWN:${unameOut}" ;;
    esac
    echo "$OS"
}

# Function to install Java
install_java() {
    echo "Checking for Java..."
    if command -v java >/dev/null 2>&1; then
        echo "Java is already installed."
    else
        echo "Java is not installed. Installing now..."
        case "$OS" in
            Linux)
                . /etc/os-release 2>/dev/null || { echo "Error: Unable to determine Linux distribution."; exit 1; }
                case "$ID" in
                    ubuntu|debian)
                        echo "Installing Java on Debian-based Linux..."
                        sudo apt update && sudo apt install -y openjdk-11-jdk
                        ;;
                    fedora|rhel|centos)
                        echo "Installing Java on RHEL-based Linux..."
                        sudo yum install -y java-11-openjdk-devel
                        ;;
                    *)
                        echo "Unsupported Linux distribution: $ID. Please install Java manually."
                        exit 1
                        ;;
                esac
                ;;
            Mac)
                echo "Installing Java on macOS..."
                if ! command -v brew >/dev/null 2>&1; then
                    echo "Error: Homebrew is not installed. Please install Homebrew from https://brew.sh and re-run this script."
                    exit 1
                fi
                brew install openjdk@11
                ;;
            Windows)
                echo "Installing Java on Windows..."
                if command -v choco >/dev/null 2>&1; then
                    choco install openjdk11 -y
                else
                    echo "Error: Chocolatey is not installed. Please install Chocolatey from https://chocolatey.org or install Java manually."
                    exit 1
                fi
                ;;
            *)
                echo "Unsupported OS: $OS. Please install Java manually."
                exit 1
                ;;
        esac
    fi
}

# Linux installation
linux_installer() {
    echo "Detected Linux. Preparing installation..."
    install_java  # Ensure Java is installed before proceeding

    . /etc/os-release 2>/dev/null || { echo "Error: Unable to determine Linux distribution."; exit 1; }

    case "$ID" in
        ubuntu|debian)
            echo "Debian-based Linux detected."
            sudo apt update && sudo apt install -y curl gnupg  # Package for GPG keys
            # fsSL -> Fail silently, suppress status, L -> follow the redirect URLs
            curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
            # tee -> takes input, perform two things: output on terminal and create a file with that input
            echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
            sudo apt update && sudo apt install -y jenkins="$JENKINS_VERSION"
            ;;
        fedora|rhel|centos)
            echo "RHEL-based Linux detected."
            sudo yum install -y curl
            sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
            sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
            sudo yum install -y jenkins-"$JENKINS_VERSION"
            ;;
        *)
            echo "Unsupported Linux distribution: $ID. Please install Jenkins manually."
            exit 1
            ;;
    esac
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    echo "Jenkins installed successfully. Access it at http://localhost:8080"
}

# macOS installation
mac_installer() {
    echo "Detected macOS. Preparing installation..."
    install_java  # Ensure Java is installed before proceeding
    if ! command -v brew >/dev/null 2>&1; then
        echo "Error: Homebrew is not installed. Please install Homebrew from https://brew.sh and re-run this script."
        exit 1
    fi
    brew tap jenkinsci/jenkins
    brew install jenkins-lts
    brew services start jenkins-lts
    echo "Jenkins installed successfully. Access it at http://localhost:8080"
}

# Windows installation
windows_installer() {
    echo "Detected Windows. Preparing installation..."
    install_java  # Ensure Java is installed before proceeding
    if command -v choco >/dev/null 2>&1; then
        echo "Chocolatey found. Installing Jenkins..."
        choco install jenkins --version="$JENKINS_VERSION" -y
        echo "Jenkins installed successfully. Ensure Jenkins service is running."
    elif grep -q Microsoft /proc/version 2>/dev/null; then
        echo "Running in WSL. Proceeding with Linux installation..."
        linux_installer
    else
        echo "Error: Unsupported Windows setup. Please install Chocolatey (https://chocolatey.org) or use WSL for Jenkins installation."
        exit 1
    fi
}

# Main function
main() {
    version_fetcher
    version_selector

    OS=$(detect_os)
    echo "Detected OS: $OS"

    case "$OS" in
        Linux)
            linux_installer
            ;;
        Mac)
            mac_installer
            ;;
        Windows)
            windows_installer
            ;;
        *)
            echo "Unsupported OS: $OS. Exiting..."
            exit 1
            ;;
    esac

    echo -e "\nInstallation complete! Access Jenkins at http://localhost:8080\n"
}

# Run the main function
main

