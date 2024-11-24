#!/bin/bash

set -e

echo "Good Morning, Pineapple."
echo "Looking very good, very nice."

# Fetch latest Jenkins LTS version using the Jenkins API
lts_version() {
    echo "Fetching latest Jenkins LTS version..."
    # Fetch the latest stable LTS version from Jenkins API
    LTS_VERSION=$(curl -s https://updates.jenkins.io/stable/latest/ | jq -r '.version')

    if [ "$LTS_VERSION" == "null" ] || [ -z "$LTS_VERSION" ]; then
        echo "Error fetching LTS version or LTS version is null. Exiting."
        exit 1
    fi

    echo "Latest Jenkins LTS Version: $LTS_VERSION"
}

# Function that installs Jenkins based on the detected OS
install_jenkins() {
    echo "Starting Jenkins installation based on your OS..."
    case "$OS" in
        Linux)
            install_linux
            ;;
        Mac)
            install_mac
            ;;
        Windows)
            install_windows
            ;;
        *)
            echo "Unsupported OS detected: $OS. Exiting..."
            exit 1
            ;;
    esac
}

# Jenkins installation for various Linux distributions
install_linux() {
    echo "Detected Linux. Installing Jenkins..."

    # Ensure Java is installed before proceeding
    install_java

    # Package manager detection
    if command -v apt >/dev/null 2>&1; then
        install_debian_based
    elif command -v yum >/dev/null 2>&1; then
        install_rhel_based
    elif command -v pacman >/dev/null 2>&1; then
        install_arch
    else
        echo "No supported package manager detected. Please install manually."
        exit 1
    fi
}

# Debian-based installation
install_debian_based() {
    echo "Installing Jenkins on Debian/Ubuntu..."
    sudo apt-get update
    curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian/ stable main" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y jenkins="$LTS_VERSION"
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    echo "Jenkins installed successfully! Access it at http://localhost:8080"
}

# RHEL/CentOS/Fedora-based installation
install_rhel_based() {
    echo "Installing Jenkins on RHEL/CentOS/Fedora..."
    sudo yum install -y java-17-openjdk-devel
    curl -fsSL https://pkg.jenkins.io/redhat/jenkins.io.key | sudo tee /etc/yum.repos.d/jenkins.repo
    sudo yum install -y jenkins-"$LTS_VERSION"
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    echo "Jenkins installed successfully! Access it at http://localhost:8080"
}

# Arch Linux installation
install_arch() {
    echo "Installing Jenkins on Arch Linux..."
    sudo pacman -Syu --noconfirm openjdk17
    sudo pacman -S --noconfirm jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    echo "Jenkins installed successfully! Access it at http://localhost:8080"
}

# macOS installation
install_mac() {
    echo "Detected macOS. Installing Jenkins..."

    # Ensure Java is installed before proceeding
    install_java

    # Install Jenkins using Homebrew
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi
    brew update
    brew tap jenkinsci/jenkins
    brew install jenkins-lts
    brew services start jenkins-lts

    echo "Jenkins installed successfully! Access it at http://localhost:8080"
}

# Windows installation
install_windows() {
    echo "Detected Windows. Installing Jenkins..."

    # Ensure Java is installed before proceeding
    install_java

    if ! command -v choco >/dev/null 2>&1; then
        echo "Chocolatey is not installed. Please install Chocolatey first."
        exit 1
    fi

    choco install jenkins --version="$LTS_VERSION" -y
    echo "Jenkins installed successfully! You can now run Jenkins from the Start menu."
}

# Check if Java is installed, and install it if not
install_java() {
    echo "Checking for Java installation..."

    if ! command -v java >/dev/null 2>&1; then
        echo "Java not found. Installing Java 17..."
        case "$OS" in
            Linux)
                sudo apt update && sudo apt install -y openjdk-17-jdk
                ;;
            Mac)
                brew install openjdk@17
                ;;
            Windows)
                echo "Please install Java manually or use Chocolatey."
                exit 1
                ;;
            *)
                echo "Unsupported OS for Java installation. Exiting..."
                exit 1
                ;;
        esac
    else
        echo "Java is already installed."
    fi
}

# Detect the operating system
detect_os() {
    echo "Detecting operating system..."
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     OS=Linux ;;
        Darwin*)    OS=Mac ;;
        CYGWIN*|MINGW*|MSYS*) OS=Windows ;;
        *)          OS="UNKNOWN:${unameOut}" ;;
    esac
    echo "Operating system detected: $OS"
}

# Main function to run the process
main() {
    detect_os         # Detect the operating system
    lts_version  # Fetch latest LTS version
    install_jenkins    # Install Jenkins based on the OS
}

# Run the main function
main
