<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>NGUYỄN NHẬT TIẾN - HỆ THỐNG DỊCH VỤ TỔNG HỢP</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --primary: #a855f7; --bg: #020617; --sidebar: #0f172a; --card: rgba(255, 255, 255, 0.05); --border: rgba(255, 255, 255, 0.1); }
        body { background: var(--bg); color: #f1f5f9; font-family: 'Inter', sans-serif; margin: 0; display: flex; height: 100vh; }
        .sidebar { width: 260px; background: var(--sidebar); border-right: 1px solid var(--border); padding: 20px; display: flex; flex-direction: column; }
        .brand { font-size: 20px; font-weight: 800; color: var(--primary); text-align: center; margin-bottom: 30px; border-bottom: 1px solid var(--border); padding-bottom: 15px; }
        .nav-link { padding: 12px; border-radius: 10px; color: #94a3b8; text-decoration: none; display: flex; align-items: center; gap: 10px; margin-bottom: 5px; transition: 0.3s; }
        .nav-link.active { background: var(--primary); color: white; }
        .main { flex: 1; padding: 40px; overflow-y: auto; }
        .card { background: var(--card); border: 1px solid var(--border); padding: 30px; border-radius: 20px; max-width: 900px; margin: 0 auto; backdrop-filter: blur(10px); }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-size: 13px; font-weight: 600; color: #a855f7; text-transform: uppercase; }
        select, input { width: 100%; padding: 14px; background: #0f172a; border: 1px solid #334155; color: white; border-radius: 10px; font-size: 15px; }
        .price-box { background: rgba(74, 222, 128, 0.1); border: 1px solid #4ade80; padding: 20px; border-radius: 15px; margin-top: 25px; display: flex; justify-content: space-between; align-items: center; }
        .price-val { font-size: 28px; font-weight: 800; color: #4ade80; }
        .btn-buy { width: 100%; padding: 18px; background: var(--primary); color: white; border: none; border-radius: 12px; font-size: 18px; font-weight: bold; cursor: pointer; margin-top: 20px; box-shadow: 0 10px 15px -3px rgba(168, 85, 247, 0.4); }
        .desc { background: #1e293b; padding: 15px; border-radius: 10px; margin-top: 10px; font-size: 13px; border-left: 4px solid var(--primary); display: none; }
    </style>
</head>
<body>

<div class="sidebar">
    <div class="brand">NGUYỄN NHẬT TIẾN</div>
    <a href="#" class="nav-link active"><i class="fa-solid fa-plus-circle"></i> Tạo đơn mới</a>
    <a href="#" class="nav-link"><i class="fa-solid fa-wallet"></i> Nạp tiền (Auto)</a>
    <a href="#" class="nav-link"><i class="fa-solid fa-history"></i> Lịch sử đơn</a>
    <div style="margin-top:auto"><a href="https://zalo.me/0966181924" class="nav-item" style="color:#4ade80; text-decoration:none"><i class="fa-solid fa-headset"></i> Hỗ trợ Zalo</a></div>
</div>

<div class="main">
    <div class="card">
        <h2 style="margin-top:0"><i class="fa-solid fa-bolt"></i> MUA DỊCH VỤ TỔNG HỢP</h2>
        
        <div class="form-group">
            <label>1. Nền tảng</label>
            <select id="plt" onchange="chgPlt()"><option value="">-- Chọn --</option></select>
        </div>

        <div class="form-group">
            <label>2. Phân loại</label>
            <select id="cat" onchange="chgCat()" disabled><option value="">-- Chọn --</option></select>
        </div>

        <div class="form-group">
            <label>3. Dịch vụ (Giá +20%)</label>
            <select id="svc" onchange="chgSvc()" disabled><option value="">-- Chọn --</option></select>
        </div>

        <div id="svc_desc" class="desc"></div>

        <div class="form-group" style="margin-top:20px;">
            <label>Link bài viết / Profile</label>
            <input type="text" id="link" placeholder="Dán link vào đây...">
        </div>

        <div class="form-group">
            <label>Số lượng</label>
            <input type="number" id="qty" value="1000" oninput="calc()">
        </div>

        <div class="price-box">
            <span>TỔNG THANH TOÁN:</span>
            <div class="price-val"><span id="total">0</span> VNĐ</div>
        </div>

        <button class="btn-buy" onclick="order()">XÁC NHẬN THANH TOÁN</button>
    </div>
</div>

<script>
// DATABASE CỰC ĐẠI - ANH TIẾN CÓ THỂ TỰ THÊM DÒNG NẾU MUỐN
const DB = {
    fb: { n: "FACEBOOK", cats: {
        f1: { n: "Like Bài Viết (Speed/Sale)", svs: [
            {n: "Like Việt SV1 (Lên nhanh)", p: 800, d: "Bảo hành 7 ngày. Max 50k."},
            {n: "Like Tây SV2 (Giá rẻ)", p: 400, d: "Không bảo hành. Lên ngay."},
            {n: "Cảm xúc (Love, Haha, Wow) SV3", p: 1200, d: "Nick thật hoạt động."}
        ]},
        f2: { n: "Theo dõi (Sub Profile)", svs: [
            {n: "Sub VIP SV1 (Bao tụt)", p: 3500, d: "Bảo hành 30 ngày. Nick có avatar."},
            {n: "Sub Rẻ SV5", p: 1500, d: "Tốc độ cực nhanh. Phù hợp buff số."},
            {n: "Sub Nick Cổ (Cực chất)", p: 5500, d: "Người dùng thật, độ tin cậy cao."}
        ]},
        f3: { n: "Thành viên Nhóm (Group)", svs: [
            {n: "Mem Công Khai SV1", p: 6000, d: "Duyệt nhanh. Nick Việt."},
            {n: "Mem Nhóm Kín SV2", p: 8500, d: "Chỉ nhận link nhóm không kiểm duyệt."}
        ]},
        f4: { n: "Fanpage (Like + Follow)", svs: [
            {n: "Page Like + Follow SV1", p: 4500, d: "Tăng cả like trang và follow."},
            {n: "Follow Page SV2 (Giá rẻ)", p: 2500, d: "Chỉ tăng lượt theo dõi trang."}
        ]},
        f5: { n: "Mắt Livestream", svs: [
            {n: "Mắt Live 30 Phút", p: 15000, d: "Duy trì ổn định trong 30p."},
            {n: "Mắt Live 60 Phút", p: 28000, d: "Hỗ trợ seeding trong live."}
        ]}
    }},
    tt: { n: "TIKTOK", cats: {
        t1: { n: "Follow TikTok", svs: [
            {n: "Follow Việt SV1 (Xịn)", p: 16000, d: "Nick thật, hỗ trợ bật kiếm tiền."},
            {n: "Follow Global SV5 (Rẻ)", p: 8500, d: "Lên nhanh, max 1M follow."}
        ]},
        t2: { n: "Like (Tim) TikTok", svs: [
            {n: "Tym Video SV1", p: 3200, d: "Tăng đề xuất cực tốt."},
            {n: "Tym Comment", p: 4500, d: "Đẩy top bình luận."}
        ]},
        t3: { n: "View TikTok", svs: [
            {n: "View Speed SV1", p: 100, d: "1 triệu view trong 30 phút."},
            {n: "View Duy Trì (Bền)", p: 250, d: "Xem hết video mới tính view."}
        ]},
        t4: { n: "Share / Favorite TikTok", svs: [
            {n: "Chia sẻ video SV1", p: 1200, d: "Kéo tương tác mạnh."},
            {n: "Lượt yêu thích SV2", p: 1500, d: "Lưu vào danh sách yêu thích."}
        ]}
    }},
    yt: { n: "YOUTUBE", cats: {
        y1: { n: "Đăng ký (Subscriber)", svs: [
            {n: "Sub YouTube Bao Tụt", p: 55000, d: "Bảo hành vĩnh viễn."},
            {n: "Sub YouTube Giá Rẻ", p: 35000, d: "Không bảo hành tụt."}
        ]},
        y2: { n: "Giờ xem (4000 Giờ)", svs: [
            {n: "Gói bật kiếm tiền 4k giờ", p: 450000, d: "Yêu cầu video dài trên 1 tiếng."}
        ]}
    }},
    gm: { n: "GOOGLE MAP", cats: {
        g1: { n: "Đánh giá 5 Sao", svs: [
            {n: "Review Nick Local Guide", p: 45000, d: "Tăng uy tín địa điểm cực mạnh."},
            {n: "Review Nick Thường", p: 25000, d: "Tăng số lượng đánh giá."}
        ]}
    }},
    tl: { n: "TELEGRAM", cats: {
        l1: { n: "Member Channel/Group", svs: [
            {n: "Mem Global SV1", p: 7500, d: "Thành viên quốc tế."},
            {n: "Mem Việt SV2 (Chất)", p: 24000, d: "Người dùng Việt thật 100%."}
        ]}
    }},
    sp: { n: "SHOPEE", cats: {
        s1: { n: "Follow Gian Hàng", svs: [
            {n: "Follow Shopee SV1", p: 15000, d: "Tăng uy tín shop mới."}
        ]}
    }},
    thr: { n: "THREADS", cats: {
        th1: { n: "Follow Threads", svs: [
            {n: "Follow Threads SV1", p: 18000, d: "Lên cực nhanh cho Threads."}
        ]}
    } }
};

const pltS = document.getElementById('plt');
const catS = document.getElementById('cat');
const svcS = document.getElementById('svc');
const totalS = document.getElementById('total');
let curP = 0;

// Load Nền tảng
for(let k in DB) pltS.innerHTML += `<option value="${k}">${DB[k].n}</option>`;

function chgPlt() {
    catS.innerHTML = '<option value="">-- Chọn --</option>';
    catS.disabled = !pltS.value;
    if(pltS.value) {
        for(let k in DB[pltS.value].cats) catS.innerHTML += `<option value="${k}">${DB[pltS.value].cats[k].n}</option>`;
    }
    chgCat();
}

function chgCat() {
    svcS.innerHTML = '<option value="">-- Chọn --</option>';
    svcS.disabled = !catS.value;
    if(catS.value) {
        DB[pltS.value].cats[catS.value].svs.forEach(s => {
            let p20 = Math.round(s.p * 1.2);
            svcS.innerHTML += `<option value="${p20}" data-d="${s.d}" data-n="${s.n}">${s.n} [${p20}đ]</option>`;
        });
    }
    chgSvc();
}

function chgSvc() {
    const dBox = document.getElementById('svc_desc');
    if(svcS.value) {
        curP = parseInt(svcS.value);
        dBox.style.display = 'block';
        dBox.innerHTML = `<strong>Mô tả:</strong> ${svcS.options[svcS.selectedIndex].dataset.d}`;
    } else {
        dBox.style.display = 'none';
        curP = 0;
    }
    calc();
}

function calc() {
    totalS.innerText = Math.round((document.getElementById('qty').value / 1000) * curP).toLocaleString();
}

function order() {
    const l = document.getElementById('link').value;
    if(!l) return alert("Nhập link anh Tiến ơi!");
    const msg = `ĐƠN HÀNG MỚI:\n- Dịch vụ: ${svcS.options[svcS.selectedIndex].dataset.n}\n- Link: ${l}\n- Tổng: ${totalS.innerText} VNĐ`;
    window.open(`https://zalo.me/0966181924?text=${encodeURIComponent(msg)}`);
}
</script>
</body>
</html>
