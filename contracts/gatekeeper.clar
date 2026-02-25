;; ============================================================
;; Contract: gatekeeper.clar
;; Purpose : Composable access control system for Web3 contracts
;; ============================================================

;; -------------------------
;; ERRORS
;; -------------------------
(define-constant ERR-NOT-OWNER       (err u20001))
(define-constant ERR-NOT-AUTHORIZED  (err u20002))
(define-constant ERR-ROLE-NOT-FOUND  (err u20003))

;; -------------------------
;; CONSTANTS
;; -------------------------
(define-constant contract-owner tx-sender)

;; -------------------------
;; STORAGE
;; -------------------------

;; Role mapping: role-name => principal => bool
(define-map roles
  { role: (string-ascii 32), user: principal }
  bool
)

;; List of all defined roles
(define-map role-list
  { role: (string-ascii 32) }
  bool
)

;; -------------------------
;; READ-ONLY HELPERS
;; -------------------------

(define-read-only (is-owner?)
  (is-eq tx-sender contract-owner)
)

(define-read-only (has-role? (role (string-ascii 32)) (user principal))
  (default-to false (map-get? roles { role: role, user: user }))
)

;; -------------------------
;; OWNER CONTROLS
;; -------------------------

(define-public (create-role (role (string-ascii 32)))
  (let ((r role))
    (begin
      (asserts! (is-owner?) ERR-NOT-OWNER)
      (map-set role-list { role: r } true)
      (ok true)
    )
  )
)

(define-public (delete-role (role (string-ascii 32)))
  (let ((r role))
    (begin
      (asserts! (is-owner?) ERR-NOT-OWNER)
      (map-delete role-list { role: r })
      (ok true)
    )
  )
)

;; -------------------------
;; ROLE ASSIGNMENT
;; -------------------------

(define-public (assign-role (role (string-ascii 32)) (user principal))
  (let ((r role))
    (begin
      (asserts! (is-some (map-get? role-list { role: r })) ERR-ROLE-NOT-FOUND)
      (asserts! (is-owner?) ERR-NOT-OWNER)
      (map-set roles { role: r, user: user } true)
      (ok true)
    )
  )
)

(define-public (revoke-role (role (string-ascii 32)) (user principal))
  (let ((r role))
    (begin
      (asserts! (is-some (map-get? role-list { role: r })) ERR-ROLE-NOT-FOUND)
      (asserts! (is-owner?) ERR-NOT-OWNER)
      (map-delete roles { role: r, user: user })
      (ok true)
    )
  )
)

;; -------------------------
;; READ INTERFACE FOR CONTRACTS
;; -------------------------

(define-read-only (can? (role (string-ascii 32)) (user principal))
  (has-role? role user)
)
