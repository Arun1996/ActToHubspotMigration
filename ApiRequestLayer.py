import json

import requests

from ActDataAccessLayer import updateResponse
from loggerModule import get_logger
import asyncio

with open('config.json', 'r') as file:
    data = file.read()
config = json.loads(data)
apikey = config['apikey']

logger = get_logger('ApiRequest')


async def fetch(session, endpoint, task, objname):  # fetching urls and mark result of execution
    querystring = {"hapikey": apikey}
    headers = {"Content-Type": "application/json"}
    async with session.post(url=endpoint, data=task['payload'], headers=headers, params=querystring) as response:
        if response.status != 200:
            # response.raise_for_status()
            # Here you need to somehow  handle 429 code if it acquired
            # In my example I just skip it.
            # if response.status == 429:
            #     task['status'] = 'done'
            task['result'] = await response.text()
            task['status'] = 'done'
            # logger.error(f"{task['id']}")

        res = await response.text()
        await updateResponse(task['id'], res, objname)
        task['result'] = res  # just to be sure we acquire data

        logger.info(f"Got result of {task['id']}")
        task['status'] = 'done'


async def fetch_all(session, endpoint, reqestList, persecond, objname):
    # convert to list of dicts
    api_task = [{'id': i.id, 'payload': i.payload, 'result': None, 'status': 'new'} for i in reqestList]
    n = 0  # counter
    while True:
        # calc how many tasks are fetching right now
        running_tasks = len([i for i in api_task if i['status'] in ['fetch']])
        # calc how many tasks are still need to be executed
        is_tasks_to_wait = len([i for i in api_task if i['status'] != 'done'])
        # check we are not in the end of list n < len()
        # check we have room for one more task
        if n < len(api_task) and running_tasks < persecond:
            api_task[n]['status'] = 'fetch'
            #
            # Here is main trick
            # If you schedule task inside running loop
            # it will start to execute sync code until find some await
            #
            asyncio.create_task(fetch(session, endpoint, api_task[n], objname))
            n += 1
            print(f'Schedule tasks {n}. '
                  f'Running {running_tasks} '
                  f'Remain {is_tasks_to_wait}')
        # Check persecond constrain and wait a sec (or period)
        if running_tasks >= persecond:
            print('Throttling')
            await asyncio.sleep(1)
        #
        # Here is another main trick
        # To keep asyncio.run (or loop.run_until_complete) executing
        # we need to wait a little than check that all tasks are done and
        # wait and so on
        if is_tasks_to_wait != 0:
            await asyncio.sleep(0.1)  # wait all tasks done
        else:
            # All tasks done
            break
    return api_task


def update(endpoint):
    querystring = {"hapikey": apikey}
    r = requests.put(endpoint, params=querystring)
    print(r.text)
