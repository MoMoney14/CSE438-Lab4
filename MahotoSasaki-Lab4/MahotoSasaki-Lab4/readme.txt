CREATIVE PORTION
1. What you implemented?
I implemented a feature that allows users to see a home screen where the most popular, latest, and upcoming movies are featured.

I saved some information(image, overview, score, title) about the favorited movies such that they can be accessed offline without internet connection. This information can be accessed from the table view when the user selects the cell in the table.

I allowed users to create their own session within the app by allowing them to authorize that the app access https://www.themoviedb.org website on their own account. I then allowed the functionality where if the user is logged in to their account and they favorite a movie inside the mobile app, the movie is automatically inside the favorites list of the website.

2. How you implemented it?
I implemented the feature by creating 3 collection views that were able to be scrolled through horizontally. I ensured that the movies can still be clicked on to show more information and be added to the favorites through the home screen.

I implemented this feature by using CoreData and saving some of the movie information that was obtained from the API into the coredata. This data can be viewed when a table cell is selected in the favorites tab menu.

I implemented this feature by creating a new tab bar button item so that it takes the user to a page where a new request token is created and the user has to authorize the request token. The LoginViewController uses WebKit to allow the user to authorize the request token. Once the user authorizes the request token, a global session_id is created to allow the user to connect to the actual TMDB website. If a user favorites a movie, a POST is made and the user is able to send the data for the favorited movie to the website so that it shows up in the website. The user can also log out of the session so that favorited movies within the app do not get uploaded to the website.

3. Why you implemented it?
I implemented the feature because it would be convenient for the user to see popular, latest, and upcoming movies on one page. This saves them the trouble of having to click through each tab bar item to see these different categories and really speeds up the process for quickly glancing at the recent movie trends.

I implemented this feature because users should be able to see general descriptions of the favorited movies offline so that they can remenisce about the past movies they favorited. During these times, the user is not necesarrily wanting to see what movies are available but they just want to see the ones that they have favorited when they are offline.

I implemented this feature because it allows for a backup storage in case you delete the app accidentally or no longer want it on your phone. This allows the user to just go to the website to see their favorite movies.
