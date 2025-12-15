// Test file validation functions

const maxSize = 5242880; // 5MB
const allowedTypes = ['image/jpeg', 'image/png', 'application/pdf'];

function testFileSize(size) {
    if (size > maxSize) {
        return { 
            valid: false, 
            error: 'File terlalu besar. Maksimal 5MB.' 
        };
    }
    return { valid: true };
}

function testFileType(mimeType) {
    if (!allowedTypes.includes(mimeType)) {
        return { 
            valid: false, 
            error: 'Tipe file tidak didukung. Gunakan JPG, PNG, atau PDF.' 
        };
    }
    return { valid: true };
}

// Test cases
console.log('=== File Size Tests ===');
console.log('1MB file:', testFileSize(1000000)); // Should pass
console.log('6MB file:', testFileSize(6000000)); // Should fail
console.log('5MB file:', testFileSize(5242880)); // Should pass (exactly max)

console.log('\n=== File Type Tests ===');
console.log('JPEG:', testFileType('image/jpeg')); // Should pass
console.log('PNG:', testFileType('image/png')); // Should pass
console.log('PDF:', testFileType('application/pdf')); // Should pass
console.log('TXT:', testFileType('text/plain')); // Should fail
console.log('DOCX:', testFileType('application/vnd.openxmlformats-officedocument.wordprocessingml.document')); // Should fail
