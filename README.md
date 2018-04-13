Orderplex
=========

Before Starting
---------------

The goals of this exercise are to:

*   Expose you to real problems that you will be expected to solve daily
*   Test your ability to write clean, conventional Rails code
*   Test your ability to write well-architected, performant code

You should approach this project as if it was going to go into production on a high-traffic website where millions of dollars are flowing through the system. Indeed, we are interested in seeing what your standard is for a project like this from a professional engineering perspective.

We expect that, excluding time taken to set up your system, you should be able to comfortably complete this exercise in roughly 3 to 6 hours. You should go as fast as you can without sacrificing quality in the submission. We would like to get a complete submission even if it takes a bit longer than expected or if you want to work on it in parts. To that end you have up to 3 days after receiving the project to finish. As a benchmark, our solution took less than 3 hours to complete in a single sitting and didn't need to extensively modify the application.

We expect you to adhere to best-practices with regard to Rails/Ruby conventions, architecture, and patterns. We encourage you to research your solution if you aren't sure of the best-practice. Feel free to use any resources available to you.

System Requirements & Setup
---------------------------

This project requires Ruby 2.3.0 and Postgres 9.5.X to be installed on your system. If you're not familiar with how to install Postgres, check out [this article](https://www.codefellows.org/blog/three-battle-tested-ways-to-install-postgresql).

To get started, change into the project's root directory and install all dependencies:

    bundle install

Next, change your Postgres username and password in the `database.yml` file to the appropriate settings for your system.

Now, create and migrate the database:

    rake db:create; rake db:migrate; rake db:seed

Since we have removed the root git repository from the app, your final task should be to initialize one and make your first commit.

    git init; git add .; git commit

At this point you should be good to go! If you run into any issues getting set up, please let us know ASAP.

Background
----------

In a hypothetical world about 65 million years after the extinction of the dinosaurs, there exists a company called Man Crates that has built a rapidly-growing e-commerce business.

Up until now they've been handling fulfillment manually, keeping track of stock on a spreadsheet and updating and tracking orders by hand. Man Crates wants to start automating the fulfillment process to improve efficiency, eliminate human error and improve customer satisfaction.

Features
--------

### #1: Order Form

To get started, we'd like to create an order form that lets customer service enter orders on behalf of the customer. This form should let a customer service representative select a product, enter a customer name, and then click a button to create the order. Here's the mockups for the form:

*   Desktop

![Desktop](https://raw.githubusercontent.com/mutalis/orderplex/master/public/new-order.png "Desktop")

*   [Mobile](https://projects.invisionapp.com/share/PRB5YP9JN#/screens/227410653)

You'll need to create an `Order` model to implement this form. In addition to the product and customer name, `Order` should have a `status` attribute that's initially set to `processing` and a `created_at` date.

To keep things simple, you can assume that each `Order` has only one `Product`. We've also created the `Product` model for you already!

### #2: Admin Order Search

Various folks within the company need to browse orders to handle customer support requests, debug the system, or analyze the business. To that end, we want to give them the ability to easily search for orders and filter them based on various criteria.

We'd like to build this interface using a server-generated page. We've created two small mockups for the view:

*   Desktop

![Desktop](https://raw.githubusercontent.com/mutalis/orderplex/master/public/filter-orders.png "Desktop")

*   [Mobile](https://invis.io/PRB5YP9JN)

`TIP:` We don't want to let anyone outside the company view the orders dashboard. **Choose and implement a method to secure the order search page. You can use any method you want, but be sure to comment about any shortcomings of the method you choose.**

### #3: Automatic Shipping Status Updates

Man Crates ships its products to customers via FedEx, which has an API to check the status of a particular shipment. We want to make sure that every order has the correct shipping status at all times.

When a order is processed, folks at the distribution center pack it all up and set it up for shipping by getting an ID from FedEx and slapping a label with said ID on the box. FedEx comes by once a day to pick up all orders that are awaiting pickup, magically moves them all over the country, and eventually delivers them to our customers' front doors.

We want to check the status of each open order every 15 minutes. Because this involves querying a third-party API, it's a good use case for an asynchronous process, which means we're going to use ActiveJob.

We've created a stub job already. **You should implement the `perform` method:**

    
        class UpdateShippingStatusJob < ActiveJob::Base
            def perform
                # IMPLEMENT ME
            end
        end
        

You can assume that an order transitions through the following states on the FedEx side: `awaiting_pickup`, `in_transit`, `out_for_delivery`, and `delivered`. You should use the same names in your code.

You can also assume that any order not in the `processing` state (the default state) will have a valid `fedex_id`.

We've implemented a FedEx client library in `lib/fedex.rb` already for you, which you should use to get an order's current shipping status from FedEx. You should also use this library to create a shipment for an order if the shipment doesn't exist. Here's the [documentation](doc/Fedex.html) for `lib/fedex.rb`.

`TIP:` Think about how to write the job in a way that is memory-efficient and performant. It could easily be the case that there are tends of thousands of orders that require shipping status updates at any given time.

`TIP:` **You shouldn't directly modify this `lib/fedex.rb`, despite any shortcomings.** Instead find other ways to ensure that the `perform` method can handle whatever cases might arise from using `lib/fedex.rb`
