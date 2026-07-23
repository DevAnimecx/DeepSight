// Test Fixture: Hardcoded Secret (Data Leakage)
// Expected: data.md agent should flag as Critical

// All values below are FAKE — used only to test data.md agent detection
const stripe = require('stripe')('sk_test_placeholder_xxxxxxxxxxxxx');
const aws = require('aws-sdk');

aws.config.update({
  accessKeyId: 'AKIA_TEST_KEY_XXXXXX',
  secretAccessKey: 'TEST_SECRET_KEY_XXXXXXXXXXXXXXX'
});

const dbPassword = 'test-password-placeholder';
const apiKey = 'AIza_TEST_KEY_FOR_TESTING_ONLY_XXXXX';

module.exports = { stripe, aws, dbPassword, apiKey };
