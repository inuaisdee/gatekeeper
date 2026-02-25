# Gatekeeper

A lightweight, composable access control system for Web3 contracts built on Stacks/Clarity.

## Overview

Gatekeeper provides role-based access control (RBAC) primitives that enable other smart contracts to query and enforce permissions. It's designed to be simple, efficient, and easily integrated into larger Web3 applications.

## Features

- **Role-Based Access Control (RBAC)** - Define and manage custom roles
- **Owner-Controlled** - Only the contract owner can create/delete roles and assign permissions
- **Composable** - External contracts can query permissions via the `can?` function
- **Efficient Storage** - Dual-map design for optimized reads and writes
- **Clear Error Handling** - Specific error codes for authorization failures

## Contract Functions

### Read-Only Functions

#### `is-owner?()`
Checks if the caller is the contract owner.
- **Returns:** `bool`

#### `has-role?(role, user)`
Checks if a user has a specific role.
- **Args:** `role: string-ascii 32`, `user: principal`
- **Returns:** `bool`

#### `can?(role, user)`
Public interface for checking user authorization. Recommended for external contract calls.
- **Args:** `role: string-ascii 32`, `user: principal`
- **Returns:** `bool`

### Public Functions (Owner Only)

#### `create-role(role)`
Creates a new role.
- **Args:** `role: string-ascii 32`
- **Returns:** `(ok bool)` or `(err u20001)` if not owner

#### `delete-role(role)`
Deletes an existing role.
- **Args:** `role: string-ascii 32`
- **Returns:** `(ok bool)` or `(err u20001)` if not owner

#### `assign-role(role, user)`
Assigns a role to a user.
- **Args:** `role: string-ascii 32`, `user: principal`
- **Returns:** `(ok bool)` or `(err u20001)` if not owner, `(err u20003)` if role not found

#### `revoke-role(role, user)`
Removes a role from a user.
- **Args:** `role: string-ascii 32`, `user: principal`
- **Returns:** `(ok bool)` or `(err u20001)` if not owner, `(err u20003)` if role not found

## Error Codes

| Code | Constant | Meaning |
|------|----------|---------|
| 20001 | `ERR-NOT-OWNER` | Caller is not the contract owner |
| 20002 | `ERR-NOT-AUTHORIZED` | User lacks required authorization |
| 20003 | `ERR-ROLE-NOT-FOUND` | Specified role does not exist |

## Usage Example

```clarity
;; Create a role
(contract-call? .gatekeeper create-role "moderator")

;; Assign role to a user
(contract-call? .gatekeeper assign-role "moderator" 'SP1234567890ABCDEF)

;; Check permissions in another contract
(if (contract-call? .gatekeeper can? "moderator" tx-sender)
  (ok "Access granted")
  (err "Access denied")
)
