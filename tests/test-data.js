// Test payment data validation

function validatePaymentData(data) {
    const errors = [];

    // Validate nominal
    if (!data.nominal || data.nominal <= 0) {
        errors.push('Nominal tidak valid atau tidak terbaca');
    }

    // Validate tanggal_transaksi
    if (!data.tanggal_transaksi) {
        errors.push('Tanggal transaksi tidak terbaca');
    } else {
        // Check if valid date format (YYYY-MM-DD)
        const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
        if (!dateRegex.test(data.tanggal_transaksi)) {
            errors.push('Format tanggal tidak valid (harus YYYY-MM-DD)');
        }
    }

    // Validate nama_pengirim
    if (!data.nama_pengirim || data.nama_pengirim.trim() === '') {
        errors.push('Nama pengirim tidak terbaca');
    }

    // Validate confidence
    if (data.confidence === 'low') {
        errors.push('Kualitas gambar kurang jelas');
    }

    return {
        isValid: errors.length === 0,
        errors: errors,
        status: errors.length === 0 ? 'MENUNGGU_VERIFIKASI' : 'GAGAL_VALIDASI'
    };
}

// Test cases
console.log('=== Payment Data Validation Tests ===\n');

// Test 1: Valid data
const testData1 = {
    nama_pengirim: 'John Doe',
    nominal: 1000000,
    tanggal_transaksi: '2025-12-15',
    metode_pembayaran: 'BCA',
    nomor_referensi: '1234567890',
    confidence: 'high'
};

console.log('Test 1 - Valid Data:');
console.log(validatePaymentData(testData1));
console.log('Expected: isValid = true\n');

// Test 2: Invalid nominal
const testData2 = {
    nama_pengirim: 'Jane Doe',
    nominal: 0,
    tanggal_transaksi: '2025-12-15',
    metode_pembayaran: 'BCA',
    confidence: 'high'
};

console.log('Test 2 - Invalid Nominal:');
console.log(validatePaymentData(testData2));
console.log('Expected: isValid = false, error about nominal\n');

// Test 3: Missing data
const testData3 = {
    nama_pengirim: null,
    nominal: null,
    tanggal_transaksi: null,
    confidence: 'low'
};

console.log('Test 3 - Missing Data:');
console.log(validatePaymentData(testData3));
console.log('Expected: isValid = false, multiple errors\n');

// Test 4: Invalid date format
const testData4 = {
    nama_pengirim: 'Bob Smith',
    nominal: 500000,
    tanggal_transaksi: '15-12-2025', // Wrong format
    metode_pembayaran: 'Mandiri',
    confidence: 'medium'
};

console.log('Test 4 - Invalid Date Format:');
console.log(validatePaymentData(testData4));
console.log('Expected: isValid = false, error about date format\n');

// Test 5: Low confidence
const testData5 = {
    nama_pengirim: 'Alice Johnson',
    nominal: 750000,
    tanggal_transaksi: '2025-12-15',
    metode_pembayaran: 'BNI',
    confidence: 'low'
};

console.log('Test 5 - Low Confidence:');
console.log(validatePaymentData(testData5));
console.log('Expected: isValid = false, error about image quality\n');

// Test 6: Empty nama_pengirim
const testData6 = {
    nama_pengirim: '   ', // Whitespace only
    nominal: 1000000,
    tanggal_transaksi: '2025-12-15',
    metode_pembayaran: 'BRI',
    confidence: 'high'
};

console.log('Test 6 - Empty Nama Pengirim:');
console.log(validatePaymentData(testData6));
console.log('Expected: isValid = false, error about nama_pengirim\n');
