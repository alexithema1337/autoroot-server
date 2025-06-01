# Auto Root Server | Local Privilege Escalation By Alexithema

**Deskripsi**
Script ini dibuat untuk mendownload, compile, dan menjalankan berbagai exploit kernel Linux dan privilege escalation berdasarkan daftar CVE. Script ini memudahkan pengetesan exploit secara otomatis dengan logging dan cleanup yang rapi.

---

## Fitur Utama / Features

* Auto-download exploit code dari URL yang sudah ditentukan
* Compile otomatis untuk exploit berbasis C (menggunakan gcc)
* Eksekusi exploit dan otomatis spawn shell jika berhasil
* Log aktivitas ke file di `/tmp/exploit_log_<timestamp>.txt`
* Cleanup file temporary secara otomatis setelah selesai
* Validasi dependency (`wget`, `gcc`) sebelum mulai
* Mendukung banyak CVE populer dan yang terbaru
* Mudah dikembangkan dan ditambah CVE baru dengan mengedit array associative `EXPLOIT_LIST`

---

## Requirement

* Linux OS (tested on Debian/Ubuntu/CentOS)
* `gcc` installed
* `wget` installed
* User dengan permission cukup (bisa user biasa, exploit akan mencoba eskalasi privilege)

---

## Cara Penggunaan / Usage

1. Download atau clone repo ini
2. Berikan permission eksekusi pada script:

   ```bash
   chmod +x exploit_runner.sh
   ```
3. Jalankan script:

   ```bash
   ./exploit_runner.sh
   ```
4. Script akan mencoba semua exploit yang ada di list, jika ada yang berhasil, akan spawn shell root.

---

## Dokumentasi Fungsi / Function Documentation

| Fungsi               | Deskripsi                                                                                                      |
| -------------------- | -------------------------------------------------------------------------------------------------------------- |
| `check_dependencies` | Memeriksa apakah program `wget` dan `gcc` tersedia, jika tidak maka script exit.                               |
| `log_message`        | Mencatat pesan ke file log dan juga ke console dengan timestamp.                                               |
| `cleanup`            | Menghapus folder temporary yang berisi source dan binary exploit setelah selesai.                              |
| `execute_exploit`    | Download source exploit dari URL, compile jika perlu, lalu eksekusi exploit tersebut.                          |
| `main`               | Fungsi utama yang menginisiasi temp dir, log info sistem, cek dependencies, dan looping untuk mencoba exploit. |

---

## Contoh Output / Sample Output

```plaintext
[2025-06-02 15:45:12] System Info: OS="Ubuntu 22.04.2 LTS", Kernel=5.19.0-25-generic, Arch=x86_64
[2025-06-02 15:45:12] Created by alexithema | asmodeus 1337
[2025-06-02 15:45:12] Trying CVE-2022-0847...
[2025-06-02 15:45:13] CVE-2022-0847 exploit succeeded
# (root shell prompt muncul di sini)
```

Jika semua exploit gagal:

```plaintext
[2025-06-02 15:50:00] Trying CVE-2022-0847...
[2025-06-02 15:50:01] CVE-2022-0847 exploit failed
...
[2025-06-02 15:55:00] All exploits failed
[2025-06-02 15:55:00] Cleaning up temporary files...
```

---

## Notes / Catatan

* Script ini hanya untuk tujuan edukasi dan penetration testing yang legal
* Jangan gunakan untuk aktivitas ilegal
* Beberapa exploit mungkin tidak cocok untuk kernel version dan distro kamu
* Periksa log di `/tmp/exploit_log_<timestamp>.txt` untuk debug
* Jalankan di lingkungan yang aman, seperti VM atau lab testing

---

## Contributors

Created by **alexithema | asmodeus 1337**

---

## License

This script is provided **as-is** without any warranty. Use at your own risk.

