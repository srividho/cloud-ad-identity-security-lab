# Cloud AD Infrastructure & Identity Security Lab

Hands-on cybersecurity lab built in **Microsoft Azure** to simulate a small enterprise Windows environment and implement identity security, security monitoring, and detection engineering.

## 🎯 Key Skills Demonstrated

- Microsoft Azure infrastructure
- Active Directory & AD DS
- Identity & Access Management (IAM)
- RBAC / least-privilege access
- Windows Security Auditing
- Group Policy (GPO)
- PowerShell security logging
- Windows Event Forwarding (WEF)
- Security event monitoring
- Detection Engineering
- Event correlation
- Account lockout detection
- Failed authentication detection
- Basic incident triage
- Security automation with PowerShell

---

## 🏗️ Architecture

```text
                    Microsoft Azure
                          |
                  Azure Virtual Network
                          |
              +-----------+-----------+
              |                       |
            DC01                  CLIENT01
       Windows Server          Windows Server
       Active Directory        Domain Joined
       DNS + WEC               Security Logs
       Detection Engine             |
              |                     |
              +------ WEF ----------+
                          |
                   ForwardedEvents
                          |
                  PowerShell Detection
                          |
                   Incident Log (CSV)
```

**Domain:** `ad.cloudlab.local`

---

## 🔐 Security Implementation

### Identity & Access Management
- Active Directory domain and OU structure
- Security groups for role-based access
- Dedicated IT Administrator group
- Centralized local Administrator access through GPO
- Domain-joined Windows endpoint

### Security Monitoring
- Windows Advanced Audit Policy
- Failed logon detection — **4625**
- Account lockout detection — **4740**
- Privileged activity monitoring — **4672**
- Process creation / termination — **4688 / 4689**
- PowerShell Script Block Logging — **4104**
- PowerShell Module Logging and Transcription

### Centralized Event Collection

Windows Event Forwarding (WEF) is configured to collect security events from `CLIENT01` into the centralized `ForwardedEvents` log on `DC01`.

---

## 🛡️ Detection Engineering

Custom PowerShell detections were developed for:

| Detection | Event | Severity |
|---|---:|---|
| Failed Logon | 4625 | Medium |
| Account Lockout | 4740 | High |
| Credential Attack Correlation | 4625 + 4740 | High |

The credential attack detector correlates repeated failed logons with an account lockout within a defined time window.

---

## 🧪 Attack Simulation & Validation

The lab was tested using controlled authentication failures and account lockouts.

Validation included:

- Generating failed authentication events
- Triggering an Active Directory account lockout
- Verifying WEF event forwarding
- Detecting security events with PowerShell
- Correlating authentication failures with lockouts
- Writing detected incidents to a structured CSV log

---

## 📸 Evidence

### Azure Infrastructure

![Azure Resource Group](screenshots/01-azure-resource-group-overview.png)

### Active Directory

![Active Directory Structure](screenshots/03-active-directory-structure.png)

### Security Groups

![AD Security Groups](screenshots/04-ad-security-groups.png)

### IAM / Local Administrator Access

![Local Admin GPO](screenshots/07-local-admin-gpo-access.png)

### Security Auditing

![Security Auditing GPO](screenshots/08-security-auditing-gpo.png)

### PowerShell Logging

![PowerShell Logging GPO](screenshots/09-powershell-logging-gpo.png)

### Centralized Event Monitoring

![WEF Forwarded Events](screenshots/10-wef-forwarded-events.png)

### Detection & Incident Logging

![Incident Log](screenshots/11-detection-incident-log.png)

### Account Lockout Detection

![Account Lockout](screenshots/12-account-lockout-event.png)

### Final Validation

![Final Lab Validation](screenshots/13-final-lab-validation.png)

---

## 📂 Project Structure

```text
cloud-ad-identity-security-lab/
│
├── architecture/
├── detection/
├── documentation/
├── screenshots/
│
├── README.md
├── LICENSE
└── .gitignore
```

### Detection Scripts

- `Detect-FailedLogons.ps1`
- `Detect-AccountLockouts.ps1`
- `Detect-CredentialAttack.ps1`

---

## 📚 Documentation

- [Architecture Documentation](./documentation/ARCHITECTURE.md)
- [Detection Logic](./documentation/DETECTION-LOGIC.md)
- [Architecture Diagram](./architecture/ARCHITECTURE.mmd)

---

## 💡 What This Project Demonstrates

This project combines **cloud infrastructure + identity security + endpoint monitoring + detection engineering** into a single practical security lab.

It demonstrates the ability to:

**Deploy → Secure → Monitor → Detect → Correlate → Respond**

---

## ⚠️ Disclaimer

This project was created for **educational and portfolio purposes** in an isolated Azure lab environment. Attack simulations were controlled and performed only against systems owned and administered by the project author.
