# FundraiserRaffle

This is a set of smart contracts inspired by a [reddit post](https://www.reddit.com/r/ethdev/comments/85jysi/any_dapp_developer_willing_to_help_with_a_small/).

The idea is to enable fundraisers to take advantage of the enthusiasm of the cryptocurrency community and leverage it for making impactful donations to meaningful charities. Motivation for donations will be created by incentivising donors through a raffle system where a random donor will receive half of the total donation.

## General Overview

### Ensuring the Charity gets the Money

A previously agreed upon ethereum address which a charity controls will be set in the smart contract before fundraising begins. This will not be able to be changed. The address will be confirmed to be valid through some form of social media post including the ethereum address from a social media account the charity controls.

### Donating

Donations will be made to the smart contract where in return for the donation, the donor will have a chance to win half of the donation. Donors only get one chance not matter how many times they donate.

## TODO
- [ ] implement donor index and donor index checking to facilitate 1 address = 1 entry
- [ ] decide on minimum donation amount in order to prevent spam from different addresses for entries
