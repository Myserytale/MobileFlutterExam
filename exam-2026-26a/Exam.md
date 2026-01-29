# Exam Requirement: Car Rental Cost App
A group of users is managing their car rental budgets using a mobile application. Users can track vehicle rentals, insurance costs, and fuel expenses.

On the server side, at least the following details are maintained:
- `id`: The unique identifier for the transaction. Integer value greater than zero.
- `date`: The date when the transaction occurred. A string in the format "YYYY-MM-DD".
- `amount`: The cost of the rental or service. A decimal value.
- `type`: The type of transaction (e.g., rental, insurance, fuel). A string of characters.
- `category`: The category of the vehicle (e.g., suv, sedan, luxury). A string of characters.
- `description`: A description of the vehicle or transaction. A string of characters.

The application should provide at least the following features:

## Main Section (Separate Screen/Activity)
> **Note:** Each feature in this section should be implemented in a separate screen unless otherwise specified.

- A. **(1p) View the list of rentals**: Using the `GET /rentals` call, users can retrieve all their rental records. If offline, the app will display an offline message and provide a retry option. Once retrieved, the data should be available on the device, regardless of whether online or offline.
- B. **(2p) View Rental Details**: By selecting a rental from the list, the user can view its details. The `GET /rental/:id` call will retrieve specific details. Once retrieved, the data should be available on the device, regardless of whether online or offline.
- C. **(1p) Add a new rental**: Users can create a new rental transaction using the `POST /rental` call by specifying all details. This feature is available online only.
- D. **(1p) Delete a rental**: Users can delete a rental record using the `DELETE /rental/:id` call by selecting it from the list. This feature is available online only.

## Reports Section (Separate Screen/Activity)
> **Note:** This section uses different API endpoints than the Main section.

**(1p) Monthly Spending Analysis**: Using the `GET /allRentals` call, the app will retrieve all records and compute the list of monthly totals, displayed in descending order.

## Insights Section (Separate Screen/Activity)
> **Note:** This section uses different API endpoints than the Main section.

**(1p) Top Vehicle Categories**: View the top 3 vehicle categories by cost. Using the same `GET /allRentals` call, the app will compute and display the top 3 categories and their total amounts in descending order.

## Additional Features
- **(1p) WebSocket Notifications**: When a new rental is added, the server will use a WebSocket channel to send the details to all connected clients. The app will display the received data in human-readable form (e.g., as a toast, snackbar, or dialog).
- **(0.5p) Progress Indicator**: A progress indicator will be displayed during server operations.
- **(0.5p) Error Handling & Logging**: Any server interaction errors will be displayed using a toast or snackbar, and all interactions (server or DB) will log a message.

## Server Info
- Location: `./server`
- Install: `npm install`
- Run: `npm start`
- Port: 2622
