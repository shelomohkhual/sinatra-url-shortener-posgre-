# User Authentication in Sinatra

## Overview

In this exercise, we will build a Sinatra application that will allow users to sign up for, log into, and then log out of your application.

## Objectives

1. Show how logging in to an application stores a user's ID into a `session` hash
2. Set up a root path and homepage for the application
3. Build a user sign-up flow with a Users model that signs in and logs in a user
4. Log out the user by clearing the `session` hash

## User Authorization: Using Sessions

### Logging In

What does it mean for a user to 'log in'? The action of logging in is the simple action of storing a user's ID in the `session` hash. Here's a basic user login flow:

1. User visits the login page and fills out a form with their email and password. They hit 'submit' to `POST` that data to a controller route.
2. That controller route accesses the user's email and password from the `params` hash. That info is used to find the appropriate user from the database with a line such as `User.find_by(email: params[:email], password: params[:password])`. **Then, that user's ID is stored as the value of `session[:user_id]`.**
3. As a result, we can access and use the `session` hash in *any other controller route* and know who is the current user by matching up a user ID with the value in `session[:user_id]`. That means that, for the duration of the session (i.e., the time between when someone logs in to and logs out of your app), the app will know who the current user is on every page.

#### A Note On Password Encryption

For the time being, we will simply store a user's password in the database in its raw form. However, that is not safe! In an upcoming lesson, we'll learn about password encryption: the act of scrambling a user's password into a super-secret code and storing a de-crypter that will be able to match up a plaintext password entered by a user with the encrypted version stored in a database.

### Logging Out

What does it mean to log out? Conceptually, it means we are terminating the session, the period of interaction between a given user and our app. The action of 'logging out' is really just the action of clearing all of the data, including the user's ID, from the `session` hash. Luckily for us, there is already a Ruby method for emptying a hash: `#clear`.

### User Registration

Before a user can sign in, they need to be able to sign up! What does it mean to 'sign up'? A new user submits their information (for example, their name, email, and password) via a form. When that form gets submitted, a `POST` request is sent to a route defined in the controller. That route will have code that does the following:

1. Gets the new user's name, email, and password from the `params` hash.
2. Uses that info to create and save a new instance of `User`. For example: `User.create(name: params[:name], email: params[:email], password: params[:password])`.
3. Signs the user in once they have completed the sign-up process. It would be annoying if you had to create a new account on a site and *then* sign in immediately afterwards. So, in the same controller route in which we create a new user, we set the `session[:user_id]` equal to the new user's ID, effectively logging them in.
4. Finally, we redirect the user somewhere else, such as their personal homepage.

## Project Structure

### Our Starter Project

The `app` folder contains the models, views and controllers that make up the core of our Sinatra application.

#### Application Controller

* The `get '/registrations/signup'` route has one responsibility: render the sign-up form view. This view can be found in `app/views/registrations/signup.erb`. Notice we have separate view sub-folders to correspond to the different controller action groupings.

* The `post '/registrations'` route is responsible for handling the `POST` request that is sent when a user hits 'submit' on the sign-up form. It will contain code that gets the new user's info from the `params` hash, creates a new user, signs them in, and then redirects them somewhere else.

* The `get '/sessions/login'` route is responsible for rendering the login form.

* The `post '/sessions'` route is responsible for receiving the `POST` request that gets sent when a user hits 'submit' on the login form. This route contains code that grabs the user's info from the `params` hash, looks to match that info against the existing entries in the user database, and, if a matching entry is found, signs the user in.

* The `get '/sessions/logout'` route is responsible for logging the user out by clearing the `session` hash.

* The `get '/users/home'` route is responsible for rendering the user's homepage view.

#### The `models` Folder

The `models` folder only contains one file because we only have one model in this app: `User`.

The code in `app/models/user.rb` will be pretty basic. We'll validate some of the attributes of our user by writing code that makes sure no one can sign up without inputting their name, email, and password.

#### The `views` Folder

This folder has a few sub-folders we want to take a look at. Since we have different controllers responsible for different functions/features, we want our `views` folder structure to match up.
* The **`views/registrations`** sub-directory contains one file, the template for the new user sign-up form. That template will be rendered by the `get '/registrations/signup'` route in our controller. This form will `POST` to the `post '/registrations'` route in our controller.
* The **`views/sessions`** sub-directory contains one file, the template for the login form. This template is rendered by the `get '/sessions/login'` route in the controller. The form on this page sends a `POST` request that is handled by the `post '/sessions'` route.
* The **`views/users`** sub-directory contains one file, the template for the user's homepage. This page is rendered by the `get '/users/home'` route in the controller.
* We also have a `home.erb` file in the top level of the `views` directory. This is the page rendered by the root route, `get '/'`.

## Release 1

### Step 1: Models and Migrations

Our `User` model will have a few attributes: a name, email, and password. Write a migration that creates a `Users` table with columns for name, email, and password. 

`bundle exec rake db:create_migration NAME=create_users`

After you have created the migration file, run `bundle exec rake db:migrate` and then run your test suite.

You'll see that you're passing a number of tests, including these:

```ruby
User
  is invalid without a name
  is invalid without a email
  is invalid without an password
```

This is because by default, the model was already provided, with a validation for those fields to be required.

### Step 2: The Root Path and the Homepage

First things first, let's set up our root path and homepage.

* Open up `app/controllers/application_controller.rb` and check out the `get '/'` route. This route should render the `app/views/home.erb` page with the following code:

```ruby
erb :home
```
* Run your test suite again with `bundle exec rspec` in the command line and you should be passing these two tests:

```bash
ApplicationController
  homepage: GET /
    responds with a 200 status code
    renders the homepage view, 'home.erb'
```
* Start up your app by running `shotgun` in the terminal. Visit the homepage at [localhost:9393](http://localhost:9393/). You should see a message that welcomes you to Recode and shows you a link to sign up and a link to log in.

* Let's look at the code behind this view. Open up `app/views/home.erb` and you should see the following:

```ruby
<h1>Welcome to Recode</h1>
  <h4>Please sign up or log in to access your @recode.edu email account</h4>
  <a href="/registrations/signup">Sign Up</a>
  <a href="/sessions/login">Log In</a>
```

Notice that we have two links, the "Sign Up" link and the "Log In" link. Let's take a closer look:

* The 'href' (destination) value of the first link is `/registrations/signup`. This means that the link points to the `get '/registrations/signup'` route.
* The 'href' value of the second link is `/sessions/login`. This means that the link points to the `get '/sessions/login'` route.

Let's move on to step 2, the building of our user sign-up flow.

### Step 3: User Sign-up

* In your controller you should see two routes dedicated to sign-up. Let's take a look at the first route, `get '/registrations/signup'`, which is responsible for rendering the sign-up template.

```ruby
get '/registrations/signup' do
    erb :'/registrations/signup'
end
```

* Navigate to [localhost:9393/registrations/signup](http://localhost:9393/registrations/signup). You should see a page that says 'Sign Up Below:'. Let's make a sign-up form!

* Open up `app/views/registrations/signup.erb`. Our signup form needs fields for name, email, and password. It needs to `POST` data to the `'/registrations'` path, so your form action should be `'/registrations'` and your form method should be `POST`.

* Once you've written your form, go ahead and add the line `puts params` inside the `post '/registrations'` route in the controller. Then, fill out the form in your browser and hit the `"Sign Up"` button.

* Hop on over to your terminal and you should see the params outputted there. It should look something like this (but with whatever info you entered into the form):

```ruby
{"name"=>"Luna Lovegood", "email"=>"luna@recode.edu", "password"=>"password"}
```

* Okay, so we're inside our `post '/registrations'` route, and we have our `params` hash that contains the user's name, email, and password. Inside the `post '/registrations'` route, place the following code:

```ruby
@user = User.new(name: params["name"], email: params["email"], password: params["password"])
@user.save
```

* With this code, we would have registered a new user.

* It would be annoying if after registering, they would still need to manually sign in. We should do that automatically. On the following line, set the `session[:user_id]` equal to our new user's ID:

```ruby
session[:user_id] = @user.id
```

* Take a look at the last line of the method:

```ruby
redirect '/users/home'
```

Now that we've signed up and logged in our user, we want to take them to their homepage.

Go ahead and run the test suite again and you should see that *almost all* of the user sign-up tests are passing.

### Step 4: Fetching the Current User

Open up the view file: `app/views/users/home.erb` and look at the following line of code:

```erb
"Welcome, <%=@user.name%>!"
```

Looks like this view is trying to operate on a `@user` variable. The only variables that a view can access are instance variables set in the controller route that renders that particular view page. Let's take a look at the route in our controller that corresponds to the `/users/home` view.

Remember, after a user signs up and is signed in via the code we wrote in the previous step, we redirect to the `'/users/home'` path.

* Take a look at the controller and look for the `get '/users/home'` route. First, this route finds the current user based on the ID value stored in the `session` hash. Then, it sets an instance variable, `@user`, equal to that found user, allowing us to access the current user in the corresponding view page. Let's set it up:

```ruby
get '/users/home' do
  @user = User.find(session[:user_id])
  erb :'/users/home'
end
```

* Run the tests again and we should be passing *all* of our user sign up tests.

### Step 5: Logging In
* Go back to your homepage and look at the second of the two links:

```ruby
<a href="/sessions/login">Log In</a>
```

* This is a link to the `get '/sessions/login'` route. Checkout the two routes defined in the controller for logging in and out. We have a `get '/sessions/login'` route and a `post '/sessions'` route.
* The `get /sessions/login'` route renders the login view page. Restart your app by executing `Ctrl + C` and then typing `shotgun` in your terminal. Navigate back to the root page, [localhost:9393](http://localhost:9393/), and click on the 'Log In' link. It should take you to a page that says 'Log In Below:'. Let's create our login form!
* Open up `app/views/sessions/login.erb`. We need a form that sends a `POST` request to `/sessions` and has input fields for email and password. Don't forget to add a submit button that says 'Log In'. Then, to test that everything is working as expected, place the line `puts params` in the `post '/sessions'` route. In your browser, fill out the form and hit 'Log In'.
* In your terminal, you should see the outputted `params` hash looking something like this (but with whatever information you entered into the login form):

```bash
{"email"=>"luna@recode.edu", "password"=>"password"}
```
* Inside the `post '/sessions'` route, let's write the lines of code that will find the correct user from the database and log them in by setting the `session[:user_id]` equal to their user ID.

```ruby
@user = User.find_by(email: params["email"], password: params["password"])
session[:user_id] = @user.id
```
* Notice that the last line of the route redirects the user to their homepage. We already coded the `'/users/home'` route in the controller to retrieve the current user based on the ID stored in `session[:user_id]`.
* Run the test suite again and you should be passing the user login tests.

### Step 6: Logging Out

* Open up `app/views/users/home.erb` and check out the following link:

```html
<a href="/sessions/logout">Log Out</a>
```

* We have a link that takes us to the `get '/sessions/logout'` route, which is responsible for logging us out by clearing the `session` hash.
* In the `get '/sessions/logout'` route in the controller, put:

```ruby
session.clear
```
* Run the test suite again, and you should be passing everything.

## Release 2

### Step 1: Add a Failure Page

* Right now, there are no possible errors. Add some error checking to your authentication to catch things like invalid username / password when logging in or an error when signing up, and redirect the user to another page if that happens to let them know.

### Step 2: Preparing to Use Bcrypt

* Note: Make sure you drop and recreate your database before proceeding, otherwise you will likely encounter errors!

* At this point, let's use the gem 'bcrypt' to salt your password and make sure that it is encrypted. Run ```bundle install```

* BCrypt will store a salted, hashed version of our users' passwords in our database in a column called password_hash. Once a password is salted and hashed, there is no way for anyone to decode it. 

* Generate a new migration file to add a column called ```password_hash``` to your user model. Drop the password column.

* In your User model, mixin the Bcrypt module
```ruby
class User < ActiveRecord::Base
  include BCrypt
end
```

### Step 3: Creating a Getter and Setter for Password

* While we have removed the password column, we would still want to refer to and access the password as 'password'. We can use this by creating a getter and setter method.

* The BCrypt module has a Password class which can be used to automatically hash a string into a password hash.

* You can access this directly, if you have not mixed in the BCrypt module

```ruby
hashed_password = BCrypt::Password.create(password) #=> hashedpassword
correct_pass = BCrypt::Password.new("hashedpassword")
correct_pass.is_password?(password) #=> true
```

* Create the getter and setters in your User model:
```ruby
class User < ActiveRecord::Base
    def password
        @password ||= Password.new(password_hash)
    end

    def password=(new_password)
        @password = Password.create(new_password)
        self.password_hash = @password
    end
end
```

* Test and make sure your registration, login and logout is working. If it does work, congratulations on having a hashed password!

## Release 3

### Warning: Do not proceed if you have not completed Release 2. Only do release 3 after completing Release 2.

### Step 1: Adding has_secure_password

* Now, add has_secure_password to your User model:
```ruby
class User < ActiveRecord::Base
  has_secure_password
end
```

* This is a special command that Ruby has to deal with passwords. By adding has_secure_password to the model, the model now automatically converts between the entered password and the hashed password. Your class also gains a new authenticate method, which authenticates takes in a password, and returns the User instance if the authentication is successful, and false is it is unsuccessful.

* Modify your application to work with has_secure_password


## Conclusion

Play around with your app a bit. Practice signing up, logging out, and logging in, and get used to the general flow.

Here are a few takeaways from this exercise:

* Separate out your views into sub-folders according to their different concerns / controller routes.
* Signing up for an app is nothing more than submitting a form, grabbing data from the `params` hash, and using it to create a new user.
* Logging in is nothing more than locating the correct user and setting the `:id` key in the `session` hash equal to their user ID.
* Logging out is accomplished by clearing all of the data from the `session` hash.

Another important takeaway is a general understanding of the flow of information between the different routes and views of an application. 

If you're still confused by the flow of signing up and logging in/out, try drawing it out. Can you map out where your web requests go from the point at which you click the "Sign Up" link all the way through until you log out and then attempt to log back in?