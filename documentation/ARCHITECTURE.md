# Cloud AD Infrastructure & Identity Security Lab

## 1. Architecture Overview

This project implements a small enterprise-style Active Directory security environment hosted in Microsoft Azure.

The environment consists of:

- DC01 — Active Directory Domain Controller
- CLIENT01 — Domain-joined Windows endpoint
- Azure Virtual Network
- Active Directory Domain Services
- DNS
- Group Policy
- Windows Event Forwarding (WEF)
- PowerShell logging
- Centralized security event collection
- Custom PowerShell security detections
- Central incident logging

---

## 2. Azure Infrastructure

### Resource Group

`rg-cloud-ad-security`

### Azure Region

`Denmark East`

### Virtual Network

`vnet-ad-security-dk`

### Subnets

| Subnet | Address Range | Purpose |
|---|---|---|
| snet-ad | 10.10.1.0/24 | Domain Controller |
| snet-client | 10.10.2.0/24 | Domain-joined endpoint |

---

## 3. Active Directory

### Domain

`ad.cloudlab.local`

### Domain Controller

`DC01.ad.cloudlab.local`

### NetBIOS Name

`AD`

### Organizational Units

```text
Lab-Users
├── Employees
├── IT
├── IT-Admins
└── Security

Groups

Lab-Computers
└── Workstations

Service Accounts

Domain Controllers
4. Identity Security Model

The lab uses role-based Active Directory security groups.

Security Groups
GG-Employees
GG-IT-Admins
GG-Security-Team
GG-Workstation-Users
Example Role Assignment
Alice Employee
    ↓
GG-Employees
    ↓
GG-Workstation-Users

Bob ITAdmin
    ↓
GG-IT-Admins
    ↓
Local Administrators on CLIENT01

Charlie Security
    ↓
GG-Security-Team
    ↓
GG-Workstation-Users

This demonstrates centralized identity and role-based access management.

5. Group Policy Security Controls

The environment uses dedicated Group Policy Objects for security configuration.

GPO-Security-Auditing

Configured to audit security-relevant activity including:

Process creation
Process termination
Account management
Logon and logoff activity
Failed authentication attempts

Important events include:

4625 — Failed logon
4672 — Special privileges assigned
4688 — Process creation
4689 — Process termination
4740 — Account lockout
GPO-PowerShell-Logging

Configured for PowerShell monitoring:

Script Block Logging
Module Logging
PowerShell Transcription

PowerShell Event ID:

4104

This provides visibility into PowerShell script execution.

GPO-Local-Admin-Access

Restricted Groups is used to control local administrator membership.

The domain security group:

GG-IT-Admins

is assigned to the local Administrators group on CLIENT01.

This demonstrates centralized privileged access management.

6. Windows Event Forwarding

Windows Event Forwarding is implemented using a source-initiated architecture.

CLIENT01
    │
    │ Security Events
    │
    │ Windows Event Forwarding
    ▼
DC01
    │
    ▼
ForwardedEvents
Collector

DC01

Source

CLIENT01

Forwarded Security Events
4625
4672
4688
4689

The WEF subscription is:

CLIENT01-Security-Monitoring

The subscription uses HTTP/WinRM communication.

The source computer is configured through Group Policy using the Subscription Manager.

7. PowerShell Security Monitoring

Custom PowerShell detection scripts process Windows security events.

Detect-FailedLogons.ps1

Detects:

Event ID 4625

Purpose:

Identify failed authentication attempts originating from CLIENT01.

Severity:

MEDIUM

Detect-AccountLockouts.ps1

Detects:

Event ID 4740

Purpose:

Identify Active Directory account lockouts.

Severity:

HIGH

Detect-CredentialAttack.ps1

Correlates:

4625 + 4740

The detection identifies multiple failed authentication attempts followed by an account lockout within a five-minute window.

Severity:

HIGH

Example detection:

4 failed authentication attempts
        ↓
Account lockout
        ↓
Potential credential attack
8. Central Incident Logging

Detected security incidents are written to:

C:\SecurityLab\Incidents\incident-log.csv

The log records:

Timestamp
Severity
Detection type
Account
Source
Event ID
Detection details

Example:

HIGH,Account Lockout,alice.employee,4740
MEDIUM,Failed Logon,alice.employee,4625
HIGH,Credential Attack,alice.employee,4740

This provides a simple SOC-style incident record.

9. Detection Flow
Windows Endpoint
       │
       ▼
Security Event
       │
       ▼
Windows Event Forwarding
       │
       ▼
DC01 ForwardedEvents
       │
       ▼
PowerShell Detection
       │
       ├── 4625 → Failed Logon
       │
       ├── 4740 → Account Lockout
       │
       └── 4625 + 4740 → Credential Attack
       │
       ▼
Central Incident Log
10. Validation

The completed environment was validated using real Windows security events.

Observed forwarded events from CLIENT01 included:

4625
4672
4688
4689

The lab also successfully demonstrated:

Failed authentication detection
Active Directory account lockout detection
Credential attack correlation
Centralized incident logging
PowerShell Script Block Logging
Domain-based privileged access control
11. Security Lessons Demonstrated

This project demonstrates practical concepts used in enterprise security operations:

Active Directory security
Identity and access management
Least-privilege administration
Group Policy security controls
Windows security auditing
PowerShell monitoring
Windows Event Forwarding
Centralized log collection
Authentication monitoring
Account lockout detection
Basic event correlation
Security incident logging
SOC-style detection engineering
12. Windows Server 2025 WEF Observation

During testing, filtered Get-WinEvent queries against the ForwardedEvents log caused an RPC error on the Windows Server 2025 collector.

Unfiltered event retrieval followed by client-side PowerShell filtering was used instead.

Example:

Get-WinEvent -LogName ForwardedEvents -MaxEvents 1000 |
    Where-Object { $_.Id -eq 4625 }

This workaround allowed centralized event analysis to continue successfully.

Disclaimer

This project is an educational cybersecurity lab created for learning, portfolio development, and security engineering practice.

The Active Directory domain, users, credentials, network configuration, and security events are lab-generated resources.

No production systems or real organizational data are used.

The project should not be interpreted as a production-ready security architecture.