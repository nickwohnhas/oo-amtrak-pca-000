---
tags: cs, comp sci, advanced logic, nested data structures, class interactions
languages: ruby
resources: 1
---

# OO Amtrak

![ticket machine](https://s3-us-west-2.amazonaws.com/web-dev-readme-photos/oo-labs/amtrak.jpg)

## Background

You've been hired by Amtrak update their ticketing machines. To accomplish this, you're going to create two classes, Ticket and Vending Machine. 

The tickets know three things: 

* The name of the station where the rider gets on
* The station name where they get off
* The name of the ticket purchaser

The vending machines know about that route that their stationed on. For instance, a ticketing machine in San Diego only knows about the Pacific Surfliner line while a ticket machine in Rhode Island only knows about the Acela Express line. This makes sense because people would rarely get a ticket from LA to Santa Barbara while they're at a train station in New York, right?

Therefore, the machines only know two things:

* The route information
* The tickets they've issued

## Route Info

The ticket vending machines will initialize with a JSON file path (for a reminder on loading JSON files, take a look [here](https://hackhands.com/ruby-read-json-file-hash/)). These JSON files look something like this:

```json
[
  {"station name": "Surf, CA",          "remaining seats": 7},
  {"station name": "Santa Barbara, CA", "remaining seats": 3},
  {"station name": "Los Angeles, CA",   "remaining seats": 2},
  {"station name": "Irvine, CA",        "remaining seats": 1},
  {"station name": "Solana Beach, CA",  "remaining seats": 2},
  {"station name": "San Diego, CA",     "remaining seats": 9}
]
```

As you can see, the JSON files hold hashes. Each hash represents a station. The hashes are arranged in the order that they appear on the route. For instance, if a rider boards at Solana Beach, they will pass through the Irvine then LA stations before arriving at their destination of Santa Barbara. 

The remaining seats are the number of seats left when the train departs from the station. Therefore, when the train closes its doors and departs from Irvine,  there is only one seat left.

## Issuing Tickets

Take a look at the above JSON. Since there is at least one remaining seat in the train at each station, the potential Solana Beach to Santa Barbara rider would be issued a ticket. Your program should remember to decrease the number of seats remaining when a ticket is issued.

Therefore, after your program creates one new ticket, the remaining seat counts at the origin and destination stations and all stations in between them should go down by one:

```json
[
  {"station name": "Surf, CA",          "remaining seats": 7},
  {"station name": "Santa Barbara, CA", "remaining seats": 2},
  {"station name": "Los Angeles, CA",   "remaining seats": 1},
  {"station name": "Irvine, CA",        "remaining seats": 0},
  {"station name": "Solana Beach, CA",  "remaining seats": 1},
  {"station name": "San Diego, CA",     "remaining seats": 9}
]
```

Now let's say a person wants to go from San Deigo to Los Angeles and the route looks like this:. Since there are no remaining seats when the train lets passengers on in Irvine, your program should not issue them a ticket.

Let's take another example, let's say that a singer wants to go from San Diego to Surf, CA with her pianist the route looks like this:

```json
[
  {"station name": "Surf, CA",          "remaining seats": 7},
  {"station name": "Santa Barbara, CA", "remaining seats": 2},
  {"station name": "Los Angeles, CA",   "remaining seats": 9},
  {"station name": "Irvine, CA",        "remaining seats": 7},
  {"station name": "Solana Beach, CA",  "remaining seats": 1},
  {"station name": "San Diego, CA",     "remaining seats": 9}
]
```

Since there are is only one remaining seat when the train lets passengers on in Solana Beach, your program should not issue the two riders any tickets.

## Instructions

This is a test-driven lab so run your testing suite to get started. It is recommended that you get all the Ticket specs to pass before moving onto the vending machine specs.

While only one custom method is tested in the spec, `purchase_tickets`, you should create helper methods for it to keep it clean. We wanted to leave the way you go about creating these helper methods up to you, but that doesn't mean your `purchase_tickets` method should be bloated.

## Resources

* [Hack.hands() - Reading a JSON File](https://hackhands.com/ruby-read-json-file-hash/)
