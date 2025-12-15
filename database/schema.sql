-- ============================================
-- Neon DB Schema for Payment Processor
-- ============================================
-- This script creates tables for storing payment data
-- Run this after n8n creates its internal tables

-- ============================================
-- Payments Table
-- ============================================
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    phone_number VARCHAR(20) NOT NULL,
    contact_name VARCHAR(255),
    sender_name VARCHAR(255),
    amount DECIMAL(15,2),
    transaction_date DATE,
    payment_method VARCHAR(100),
    reference_number VARCHAR(100),
    status VARCHAR(50) DEFAULT 'MENUNGGU_VERIFIKASI',
    confidence VARCHAR(20),
    message_id VARCHAR(255) UNIQUE,
    raw_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comments
COMMENT ON TABLE payments IS 'Stores successful payment proof submissions';
COMMENT ON COLUMN payments.phone_number IS 'WhatsApp number of sender';
COMMENT ON COLUMN payments.sender_name IS 'Name extracted from payment proof';
COMMENT ON COLUMN payments.amount IS 'Payment amount in IDR';
COMMENT ON COLUMN payments.status IS 'MENUNGGU_VERIFIKASI, VERIFIED, REJECTED';

-- ============================================
-- Failed Validations Table
-- ============================================
CREATE TABLE IF NOT EXISTS failed_validations (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    phone_number VARCHAR(20) NOT NULL,
    contact_name VARCHAR(255),
    errors TEXT,
    message_id VARCHAR(255),
    raw_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_payments_phone ON payments(phone_number);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_date ON payments(transaction_date);
CREATE INDEX IF NOT EXISTS idx_payments_created ON payments(created_at DESC);

-- ============================================
-- Triggers
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_payments_updated_at ON payments;
CREATE TRIGGER update_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Views
-- ============================================
CREATE OR REPLACE VIEW daily_payment_summary AS
SELECT 
    DATE(transaction_date) as date,
    COUNT(*) as total_transactions,
    SUM(amount) as total_amount,
    AVG(amount) as avg_amount
FROM payments
GROUP BY DATE(transaction_date)
ORDER BY date DESC;

-- ============================================
-- Schema Version
-- ============================================
CREATE TABLE IF NOT EXISTS schema_version (
    version VARCHAR(10) PRIMARY KEY,
    applied_at TIMESTAMPTZ DEFAULT NOW(),
    description TEXT
);

INSERT INTO schema_version (version, description) 
VALUES ('1.0.0', 'Initial schema for payment processor')
ON CONFLICT (version) DO NOTHING;
