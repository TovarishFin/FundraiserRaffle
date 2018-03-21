# FundraiserRaffle

This is a set of smart contracts inspired by a [reddit post](https://www.reddit.com/r/ethdev/comments/85jysi/any_dapp_developer_willing_to_help_with_a_small/).

The idea is to enable fundraisers to take advantage of the enthusiasm of the cryptocurrency community and leverage it for making impactful donations to meaningful charities. Motivation for donations will be created by incentivising donors through a raffle system where a random donor will receive half of the total donation.

## General Overview

### Ensuring the Charity gets the Money

A previously agreed upon ethereum address which a charity controls will be set in the smart contract before fundraising begins. This will not be able to be changed. The address will be confirmed to be valid through some form of social media post including the ethereum address from a social media account the charity controls.

### Starting the Raffle

Donations are not accepted until the owner of the contract moves the contract into `Active` stage. Once when this has happened donations can happen until the `endDate`.

### Donating

Donations will be made to the smart contract where in return for the donation, the donor will have a chance to win half of the donation. Donors only get one chance not matter how many times they donate.

### Donation End

An end date is given to the contract at the start. When this end date has occurred, no more donations can be made. At this point, anyone can get the winner by triggering a call to the `RandomNumberGenerator` contract. This contract uses oraclize to get secure, random number from outside of the ethereum blockchain. This random number is used to pick the raffle winner at random.

### Winner claiming

The winner chosen in the previous section is able to claim his/her winnings after donations have ended and the winner has been chosen by anyone calling the `getWinner` function. The winnable amount is set to 0 after the winnings have been claimed in order to prevent duplicate claims.

### charity claiming

The charity, same as winner, is able to claim after donations are over and anyone has called `getWinner`.

## TODO
- [ ] implement donor index and donor index checking to facilitate 1 address = 1 entry
- [ ] decide on minimum donation amount in order to prevent spam from different addresses for entries
