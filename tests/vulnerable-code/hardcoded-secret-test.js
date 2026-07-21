// Test Fixture: Hardcoded Secret (Data Leakage)
// Expected: data.md agent should flag as Critical

const stripe = require('stripe')('sk_live_51MXXXXXXXXXXXXXXX');
const aws = require('aws-sdk');

aws.config.update({
  accessKeyId: 'AKIAIOSFODNN7EXAMPLE',
  secretAccessKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'
});

const dbPassword = 'SuperSecret123!';
const apiKey = 'AIzaSyD-9tSrke72PouQMnMX-a7eZSW0jkFMBWY';

module.exports = { stripe, aws, dbPassword, apiKey };
