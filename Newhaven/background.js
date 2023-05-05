const { cfg } = require('../.config.json');


async function Connect_Halo() {

    const data = {
        grant_type: 'client_credentials',
        client_id: "a363db10-e8ba-43d4-92c5-1b3c7fabc2da",
        client_secret: "b25ff438-4bbc-42ca-a83e-763f4e0e8b52-b9ae6650-1bea-4bcb-b0d1-fa8096c86e33",
        scope: 'all'
    }

    const options = {
    method: 'POST',
    body: data
    };
    const response = await fetch("https://jinbait.halopsa.com/auth/token", options);
    console.log(response)
    console.log(response.resource)
    return response
}

Connect_Halo().catch(error => console.error(error));

