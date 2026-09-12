# PORTCHECK

Lists all open (listening) TCP and UDP ports on Linux and macOS, along with the address, owning process, and state. Run with `sudo` for full process names and PIDs.

---

| Column   | Meaning                                      |
| -------- | --------------------------------------------- |
| PROTO    | Protocol (TCP or UDP).                        |
| ADDRESS  | Local address the port is bound to.           |
| PORT     | Port number.                                  |
| PROCESS  | Process name and PID (if permissions allow).  |
| STATE    | Socket state (e.g. LISTEN).                   |

---

**Usage:**

```bash
./PORTCHECK.rb
```

---

Short and clean.. 🧹