---
layout: post
title: Set up an easy aws architecture for a mobile app
date: '2020-07-06 15:54:09 +0200'
categories: aws
permalink: /:categories/post
tags: [aws, mobile]
shortPost: "true"
---

We always think that setting up an end-end architecture for a mobile application is a big task.

But with aws it's super simple and it provides all the readymade components to put into use immediately.

Let's break down into 8 easy steps.

1. **Amazon Cognito** - It's an identity service provider
   
    Mobile users get their identity tokens by sending their credentials and then they are allowed access aws resources

1. **Amazon Simple Storage Service** -  In short its called **S3** used for saving files
    
    Mobile user related files such as images, audios, document's and so on .. can be saved in this S3

1. **Amazon Cloudfront** - It's a CDN (Content Delivery Network) for providing quick access to files

    Mobile users can access the files saved in S3 via cloudfront

1. **Amazon API Gateway** - It redirects the users to the requested resource

    When mobile users requests any content, it redirects to the proper resource to satisfy the request from the users

1. **Amazon Lambda** - It's a piece of code that runs based on the request

    Mobile users can perform variety of operations like getPost, addLikes, comments etc.., based on the request from the API gateway

1. **Amazon DynamoDB** -  It's a datastore that helps to create tables to manage data

    Mobile users data can be saved in this for later retreival

1. **Amazon CloudSearch** - It provides an interface to search data that has been saved from the dynamoDB

    Mobile users can search for their data using this service 

1. **Amazon Simple Notification Service** - In short it's called **SNS** which provides push notification service to delivery content

    Mobile users receive push notifications based on their interest or some actions to get notified 
