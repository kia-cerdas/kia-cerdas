-- Add source field to rujukan table to track referral origin
-- This helps distinguish between referrals from different sources (preeklampsia, anc, dm_gestasional, etc.)

ALTER TABLE rujukan ADD COLUMN source VARCHAR(50);

-- Set default value for existing records
UPDATE rujukan SET source = 'anc' WHERE source IS NULL;

-- Add index for better filtering performance
CREATE INDEX idx_rujukan_source ON rujukan(source);
