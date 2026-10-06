<?php

namespace App\Http\Controllers;

use App\Models\News;
use Illuminate\Http\Request;
use DOMDocument;
use DOMXPath;

class NewsController extends Controller
{
    /**
     * Tampilkan daftar berita & pengumuman aktif.
     * Otomatis melakukan sinkronisasi dengan Portal Resmi Dinsos Jatim (dinsos.jatimprov.go.id).
     */
    public function index(Request $request)
    {
        if (News::count() === 0) {
            $this->syncFromOfficialPortal();
            if (News::count() === 0) {
                foreach ($this->getDefaultNewsItems() as $item) {
                    News::create($item);
                }
            }
        }

        $news = News::where('is_active', true)
            ->orderBy('id', 'asc')
            ->get();

        $baseUrl = config('app.url', 'http://20.244.48.18');
        foreach ($news as $item) {
            if (empty($item->image) || str_contains($item->image, 'dinsos.jatimprov.go.id')) {
                $imgId = (($item->id - 1) % 6) + 1;
                $item->image = $baseUrl . "/images/news/news_{$imgId}.jpg";
                News::where('id', $item->id)->update(['image' => $item->image]);
            }
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Daftar berita terkini berhasil diambil.',
            'source' => 'https://dinsos.jatimprov.go.id/',
            'data' => $news,
        ], 200);
    }

    /**
     * Endpoint manual untuk memaksa sinkronisasi berita dari Portal Resmi Dinsos Jatim.
     */
    public function sync(Request $request)
    {
        $count = $this->syncFromOfficialPortal();

        return response()->json([
            'status' => 'success',
            'message' => "Berhasil menyinkronkan {$count} berita terbaru dari Portal Dinsos Jatim.",
            'data' => News::where('is_active', true)->orderBy('id', 'asc')->get(),
        ], 200);
    }

    /**
     * Tambah berita / pengumuman manual.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'desc'  => 'required|string',
            'tag'   => 'nullable|string|max:50',
            'date'  => 'nullable|string|max:50',
            'image' => 'nullable|string',
            'author'=> 'nullable|string|max:100',
        ]);

        if (empty($validated['tag'])) $validated['tag'] = 'PENGUMUMAN';
        if (empty($validated['date'])) $validated['date'] = date('d M Y');

        $news = News::create($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Berita berhasil ditambahkan.',
            'data' => $news,
        ], 201);
    }

    /**
     * Update berita / pengumuman.
     */
    public function update(Request $request, $id)
    {
        $news = News::findOrFail($id);
        $validated = $request->validate([
            'title'     => 'sometimes|required|string|max:255',
            'desc'      => 'sometimes|required|string',
            'tag'       => 'nullable|string|max:50',
            'date'      => 'nullable|string|max:50',
            'image'     => 'nullable|string',
            'author'    => 'nullable|string|max:100',
            'is_active' => 'nullable|boolean',
        ]);

        $news->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Berita berhasil diperbarui.',
            'data' => $news,
        ], 200);
    }

    /**
     * Hapus berita / pengumuman.
     */
    public function destroy($id)
    {
        $news = News::findOrFail($id);
        $news->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Berita berhasil dihapus.',
        ], 200);
    }

    /**
     * Sinkronisasi otomatis berita real-time langsung dari Portal Resmi Dinsos Jatim.
     */
    private function syncFromOfficialPortal()
    {
        try {
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, 'https://dinsos.jatimprov.go.id/');
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
            curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($ch, CURLOPT_TIMEOUT, 12);
            $html = curl_exec($ch);
            curl_close($ch);

            if (!$html) {
                return 0;
            }

            $dom = new DOMDocument();
            @$dom->loadHTML($html);
            $xpath = new DOMXPath($dom);

            $cards = $xpath->query("//div[contains(@class, 'our-blogs')]");
            if ($cards->length === 0) {
                return 0;
            }

            $syncedItems = [];

            foreach ($cards as $card) {
                $imgNode = $xpath->query(".//div[contains(@class, 'blogs-img')]//img", $card)->item(0);
                $imgSrc = $imgNode ? $imgNode->getAttribute('src') : '';

                $tagNode = $xpath->query(".//div[contains(@class, 'blogs-info')]/span", $card)->item(0);
                $tag = $tagNode ? trim($tagNode->textContent) : 'DINSOS JATIM';

                $titleNode = $xpath->query(".//div[contains(@class, 'blogs-info')]//h4", $card)->item(0);
                $rawTitle = $titleNode ? trim($titleNode->textContent) : '';

                $linkNode = $xpath->query(".//div[contains(@class, 'blogs-info')]/a", $card)->item(0);
                $url = $linkNode ? $linkNode->getAttribute('href') : '';

                $timeNode = $xpath->query(".//span[contains(@class, 'blogs-time')]", $card)->item(0);
                $dateStr = $timeNode ? trim($timeNode->textContent) : date('d M Y');

                // Jika judul terpotong '...', formatkan dari slug URL untuk mendapatkan judul lengkap
                if (empty($rawTitle) || str_ends_with($rawTitle, '...')) {
                    $slug = basename($url);
                    if (!empty($slug)) {
                        $rawTitle = ucwords(str_replace('-', ' ', $slug));
                    }
                }

                $excerpt = "Berita resmi kegiatan Dinas Sosial Provinsi Jawa Timur. Klik tombol 'Baca Selengkapnya' untuk membuka liputan dan dokumentasi lengkap di website resmi Dinsos Jatim.";

                $syncedItems[] = [
                    'tag'       => strtoupper($tag),
                    'title'     => $rawTitle,
                    'desc'      => $excerpt,
                    'date'      => $dateStr,
                    'image'     => $imgSrc,
                    'author'    => 'Dinas Sosial Prov. Jatim',
                    'is_active' => true,
                ];
            }

            if (!empty($syncedItems)) {
                // Perbarui data berita di tabel
                News::truncate();
                foreach ($syncedItems as $item) {
                    News::create($item);
                }
                return count($syncedItems);
            }
        } catch (\Throwable $e) {
            // Jika ada kendala koneksi eksternal, biarkan data lokal yang ada tetap tampil
        }

        return 0;
    }

    private function getDefaultNewsItems(): array
    {
        $baseUrl = config('app.url', 'http://20.244.48.18');
        return [
            [
                'tag'       => 'SEKRETARIAT',
                'title'     => 'Ziarah ke Makam Bung Karno dan Gubernur Jatim Terdahulu, Refleksi 81 Tahun Jawa Timur Unggul dan Berkelanjutan',
                'desc'      => 'Peringatan hari jadi Pemprov Jawa Timur dipimpin jajaran pimpinan dan keluarga besar Dinas Sosial Provinsi Jawa Timur.',
                'date'      => '05 Okt 2026',
                'image'     => $baseUrl . '/images/news/news_1.jpg',
                'author'    => 'Dinas Sosial Prov. Jatim',
                'is_active' => true,
            ],
            [
                'tag'       => 'REHABILITASI SOSIAL',
                'title'     => 'JSC Kembali Dampingi Keluarga Gondham Prakoso Korban Kecelakaan KM Virgo Transport 8',
                'desc'      => 'Tim Jatim Social Care (JSC) Dinas Sosial Jatim sigap memberikan pendampingan psikososial dan pemenuhan kebutuhan dasar bagi keluarga korban.',
                'date'      => '05 Okt 2026',
                'image'     => $baseUrl . '/images/news/news_2.jpg',
                'author'    => 'Dinas Sosial Prov. Jatim',
                'is_active' => true,
            ],
            [
                'tag'       => 'UNIT PELAKSANA TEKNIS',
                'title'     => 'Tindak Lanjut Penjangkauan Pemprov Jatim, UPT PSTW Jombang Terima dan Asramakan Lansia Terlantar Milastri',
                'desc'      => 'Dinas Sosial Provinsi Jawa Timur memastikan setiap lansia rentan dan terlantar mendapatkan hunian layak, perawatan medis, dan bimbingan sosial.',
                'date'      => '05 Okt 2026',
                'image'     => $baseUrl . '/images/news/news_3.jpg',
                'author'    => 'Dinas Sosial Prov. Jatim',
                'is_active' => true,
            ],
            [
                'tag'       => 'UNIT PELAKSANA TEKNIS',
                'title'     => 'Pemprov Jatim - UPT PSTW Jombang Laksanakan Pemulasaraan Jenazah Penerima Manfaat Suparmi',
                'desc'      => 'Pelayanan komprehensif hingga peristirahatan terakhir bagi penerima manfaat terlantar dilaksanakan secara khidmat dan penuh rasa hormat.',
                'date'      => '05 Okt 2026',
                'image'     => $baseUrl . '/images/news/news_4.jpg',
                'author'    => 'Dinas Sosial Prov. Jatim',
                'is_active' => true,
            ],
            [
                'tag'       => 'UNIT PELAKSANA TEKNIS',
                'title'     => 'UPT PSTW Jombang Gelar Upacara Hari Kesaktian Pancasila',
                'desc'      => 'Seluruh pegawai dan penerima manfaat bersama-sama meneguhkan nilai-nilai kebangsaan dan persatuan dalam pengabdian sosial.',
                'date'      => '01 Okt 2026',
                'image'     => $baseUrl . '/images/news/news_5.jpg',
                'author'    => 'Dinas Sosial Prov. Jatim',
                'is_active' => true,
            ],
            [
                'tag'       => 'PENGUMUMAN OPERASIONAL',
                'title'     => 'Uji Emisi & Servis Rutin Armada Tahap 1 Selesai Dilaksanakan',
                'desc'      => 'Seluruh kendaraan dinas siap untuk penugasan luar kota dengan kondisi prima demi kelancaran tugas pelayanan sosial di seluruh Jawa Timur.',
                'date'      => '28 Sep 2026',
                'image'     => $baseUrl . '/images/news/news_6.jpg',
                'author'    => 'Subbag Tata Usaha & Aset',
                'is_active' => true,
            ],
        ];
    }
}