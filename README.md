# Digicourse
An online course app powered by RoR api only mode.

## Table of Contents
* [General Information](#general-information)
* [Technologies Used](#technologies-used)
* [Setup](#setup)
* [Usage](#usage)
* [Automated test runners](#automated-test-runners)

## General Information
Digicourse is an online platform to perform tasks as follows:
1. Common POST API to create a course & its tutors.
2. GET API to list all the courses along with their tutors.

## Technologies Used
- Ruby - 3.1.2
- Rails - 7.0.8.4
- PostgreSQL

## Setup

Install it using below steps:

```
$ git clone https://github.com/aruncsengr/digicourse.git
$ rvm use ruby-3.1.2@digicourse --create
$ cd digicourse
$ bundle
$ rake db:create
$ rake db:migrate
```

## Usage

**To kickstart app**

```
$ rails s -p 3000
```

## Automated test runners

**To run all test cases**

```
$ rspec --format documentation
```
which results
```
Course
  is expected to have many tutors
  validations uniqueness
    is expected to validate that :title cannot be empty/falsy
    uniqueness
      is expected to validate that :title is case-sensitively unique

Tutor
  is expected to belong to course required: true
  validations uniqueness
    is expected to validate that :first_name cannot be empty/falsy
    is expected to validate that :email cannot be empty/falsy
    uniqueness
      is expected to validate that :email is case-sensitively unique

Api::V1::courses
  POST /create
    when the request is valid
      returns status code 201
      creates a course with its tutors
    when the request is invalid
      when course title is blank
        returns status code 422
        returns a validation failure error details
        does not create a new course
      when course title is duplicate
        returns status code 422
        returns a validation failure error details
        does not create a new course
      when tutors payload data is invalid
        when email is blank
          returns status code 422
          returns a validation failure error details
          does not create a course with tutor
  GET /index
    returns status code 200
    renders a successful response of course with tutors
    pagination
      when page params are valid
        returns status code 200
      when page number is invalid
        returns status code 400

Api::V1::CoursesController
  routing
    routes to #index
    routes to #create
```
