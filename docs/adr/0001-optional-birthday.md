# Birthday is optional, with a required month and year and an optional day

## Context

Circle is a birthday tracker, so a person's birthday was originally a required field: the day was mandatory and the month defaulted to January. That forced a fake January date whenever someone was added without a known birthday — the common case when quickly capturing just a name.

## Decision

A birthday is optional and has three states: **no birthday**, a **day-less birthday** (month and year, day unknown), and a **full birthday** (month, day, year). When a birthday is present, the **month and year are required** and the **day is optional**, revealed behind an "Add day" checkbox.

This is deliberately the reverse of Google Contacts, which requires the day and makes the year optional. We require the year because it keeps every recorded birthday orderable and gives the age, and make the day optional because a birth month and year are more often known than the exact day.

## Consequences

- The birthday fields become nullable; a null month means "no birthday".
- A day-less birthday cannot be counted down, so it is excluded from the "next birthday" hint but still listed in the Birthdays list, ordered at the start of its month and shown without a day count.
- Existing records that have a day but no year violate the new rule and must supply a year on their next edit. We accepted that one-time friction rather than migrating stored data.
