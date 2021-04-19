---
title: Valheim Backup
categories: [Software]
tags: [software, valheim, c#]
pin: true
---
1. TOC
{:toc}

# Valheim Backup

A C# application to perform automated backups of [Valheim](https://store.steampowered.com/app/892970/Valheim/) world files.

## Why
One of the hottest games on Steam since it's release [Valheim](https://store.steampowered.com/app/892970/Valheim/) has been an amazingly fun game to play. I noticed a lot of people on discord and forums talking about having lost data due to some bugs, and decided to do something about it.

## What
I decided to develop the [ValheimBackup](https://github.com/slimnate/ValheimBackup) application, a WPF application and companion Windows Service that can automatically backup world files by connecting to an FTP server and periodically downloading the files to the local disk. In this article, I will go over the design and development of the software, including details on problems I had to solve along the way.