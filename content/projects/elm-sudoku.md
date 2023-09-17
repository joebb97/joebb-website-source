---
title: "Elm Sudoku Solver"
date: 2021-01-30
draft: false
categories: [elm]
author: Joey Buiteweg
---

## The Finished Project

It lives [here on CF Pages](https://elm-sudoku.pages.dev/)

The source code lives [here on GitHub](https://github.com/joebb97/elm_sudoku/tree/master)

## Supported Functionality

This app can solve user specified [Sudoku](https://en.wikipedia.org/wiki/Sudoku) boards, as well as generate boards for users to test their abilities on.

Both user specified and generated boards can be solved by clicking the "solve" button.

The solver can solve the "world's hardest Sudoku board" (shown below) in roughly a second. Feel free to try it out!
![board](/sudoku.jpg) 

_Note: The "wikipedia board" button generates the same board from the Wikipedia article on Sudoku, which can be solved by the user or the solver. It was used for testing purposes._

## Quick Bullets

In this project I:

* Learned a new frontend, functional programming language, [elm](https://elm-lang.org/), and applied what I learned to a sample problem.

* Designed the HTML, CSS, and algorithms for a Sudoku player and solver.

* Created an efficient solution to the Sudoku Constraint Satisfaction Problem (CSP) using a backtracking algorithm with the Minimum Remaining Value (MRV) heuristic.

* Constructed data model and transformation logic for handling updates to the Sudoku board.

* Enforced Sudoku rules when receiving input from a player so that the game functions correctly.

* Leveraged help from the [Elm community](https://faq.elm-community.org/), mainly the Slack workspace, to get past roadblocks faced during the project.

## My Goals

My goals in this project were to:

* Learn a functional language to make adopting the paradigm easier in future projects and in my work.

* Increase my ability to contribute correct, efficient, code to the frontends of projects, and further myself as an all-stack developer.
    * I love almost every aspect of computing, from logic gates to firmware and operating systems all the way up to web systems!

* Make a simple, efficient, and mildly useful web application.

I feel accomplished these goals in this project.

## Reflections

It might be nice to support a "clear" button that keeps the same generated board, in case the user wants to start over. I'll add this functionality if enough people request it.

It might be nice to support importing and exporting boards, but since I'm unaware of a universal format for storing sudoku boards I don't see much utility to this.
