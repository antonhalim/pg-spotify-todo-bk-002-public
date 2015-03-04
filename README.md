---
tags: sql, introductory, insert, todo
languages: sql, ruby
resources: 0
---

# SQL Spotify Songs

## Contents

1. Quick Notes
2. Background
3. Instructions
4. Hint

## Quick Note

This lab will add a table the spotify database go ahead and create that database now:

```
> createdb spotify
```

## Background

The table `songs` has been created for you already. It looks like this:

|column|type|
|------|----|
|id    |serial|
|track_name|text|
|artist|text|
|album|text|
|url|text|
|num_streams|integer|

Your job is to add every song that is in Spotify's top charts for this week to the `songs` table. Take a look at that JSON [here](http://charts.spotify.com/api/tracks/most_streamed/us/weekly/latest). This JSON has already been opened and loaded and saved as `@data`.

What you need to do is to iterate through every song in `@data` and add it to the database with the correct track name, artist, album, url, and number of streams.

## Instructions

Go ahead and open `lib/data_loader.rb`. You'll be adding code to these methods in this order:

1. `#extract_tracks`
2. `#add_song_to_db`
3. `#add_songs_to_db`

Feel free to make helper methods for `#add_song_to_db`. In fact, you probably should.

## Hint

If you need help figuring out how to make the database execute a string, take a look at the code below:

```ruby
@db = PG::Connection.open(:dbname => 'music', host: 'localhost')

create_sql = <<-SQL
  CREATE TABLE albums(
    id SERIAL,
    artist TEXT,
    name TEXT
  );
SQL

@db.exec(create_sql)

```
