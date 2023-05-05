# Rimfire

*Rimfire* is for interfacing with HaloPSA, and implementing OpenAI's API for ticket admin.
Named for the 1948 Melbourne Cup Winner.

## Setup

In your .config file, you will require:
```json
{
    "HALO_URL": "https://your.halo.url",
    "HALO_ID": "your_client_id",
    "HALO_SECRET": "your_client_secret",
    "OPENAI_KEY": "your_openai_api_key"
}
```
Note that different implementations of HaloPSA may not work/make sense with Rimfire. This is just to suit my own workflow.

## Main Menu

-  ### List today's open Customer Service tickets
When tickets are listed, they are colour coded, and displayed with status info, user and client info, etc.

- ### New/Unresponded Tickets
Same as above, but only tickets with the 'New' status.

- ### Tickets by Client
Presents you to a list of clients to select from.

- ### q
'q' in the main menu will exit Rimfire.

