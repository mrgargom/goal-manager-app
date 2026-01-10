# Generated TypeScript README
This README will guide you through the process of using the generated JavaScript SDK package for the connector `example`. It will also provide examples on how to use your generated SDK to call your Data Connect queries and mutations.

***NOTE:** This README is generated alongside the generated SDK. If you make changes to this file, they will be overwritten when the SDK is regenerated.*

# Table of Contents
- [**Overview**](#generated-javascript-readme)
- [**Accessing the connector**](#accessing-the-connector)
  - [*Connecting to the local Emulator*](#connecting-to-the-local-emulator)
- [**Queries**](#queries)
  - [*GetGoals*](#getgoals)
- [**Mutations**](#mutations)
  - [*CreateGoal*](#creategoal)
  - [*UpdateTask*](#updatetask)
  - [*CreateUser*](#createuser)

# Accessing the connector
A connector is a collection of Queries and Mutations. One SDK is generated for each connector - this SDK is generated for the connector `example`. You can find more information about connectors in the [Data Connect documentation](https://firebase.google.com/docs/data-connect#how-does).

You can use this generated SDK by importing from the package `@dataconnect/generated` as shown below. Both CommonJS and ESM imports are supported.

You can also follow the instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#set-client).

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@dataconnect/generated';

const dataConnect = getDataConnect(connectorConfig);
```

## Connecting to the local Emulator
By default, the connector will connect to the production service.

To connect to the emulator, you can use the following code.
You can also follow the emulator instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#instrument-clients).

```typescript
import { connectDataConnectEmulator, getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@dataconnect/generated';

const dataConnect = getDataConnect(connectorConfig);
connectDataConnectEmulator(dataConnect, 'localhost', 9399);
```

After it's initialized, you can call your Data Connect [queries](#queries) and [mutations](#mutations) from your generated SDK.

# Queries

There are two ways to execute a Data Connect Query using the generated Web SDK:
- Using a Query Reference function, which returns a `QueryRef`
  - The `QueryRef` can be used as an argument to `executeQuery()`, which will execute the Query and return a `QueryPromise`
- Using an action shortcut function, which returns a `QueryPromise`
  - Calling the action shortcut function will execute the Query and return a `QueryPromise`

The following is true for both the action shortcut function and the `QueryRef` function:
- The `QueryPromise` returned will resolve to the result of the Query once it has finished executing
- If the Query accepts arguments, both the action shortcut function and the `QueryRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Query
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `example` connector's generated functions to execute each query. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-queries).

## GetGoals
You can execute the `GetGoals` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getGoals(): QueryPromise<GetGoalsData, undefined>;

interface GetGoalsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetGoalsData, undefined>;
}
export const getGoalsRef: GetGoalsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getGoals(dc: DataConnect): QueryPromise<GetGoalsData, undefined>;

interface GetGoalsRef {
  ...
  (dc: DataConnect): QueryRef<GetGoalsData, undefined>;
}
export const getGoalsRef: GetGoalsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getGoalsRef:
```typescript
const name = getGoalsRef.operationName;
console.log(name);
```

### Variables
The `GetGoals` query has no variables.
### Return Type
Recall that executing the `GetGoals` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetGoalsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetGoalsData {
  goals: ({
    id: UUIDString;
    title: string;
    description?: string | null;
    priority?: string | null;
    status: string;
    targetDate: DateString;
  } & Goal_Key)[];
}
```
### Using `GetGoals`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getGoals } from '@dataconnect/generated';


// Call the `getGoals()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getGoals();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getGoals(dataConnect);

console.log(data.goals);

// Or, you can use the `Promise` API.
getGoals().then((response) => {
  const data = response.data;
  console.log(data.goals);
});
```

### Using `GetGoals`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getGoalsRef } from '@dataconnect/generated';


// Call the `getGoalsRef()` function to get a reference to the query.
const ref = getGoalsRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getGoalsRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.goals);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.goals);
});
```

# Mutations

There are two ways to execute a Data Connect Mutation using the generated Web SDK:
- Using a Mutation Reference function, which returns a `MutationRef`
  - The `MutationRef` can be used as an argument to `executeMutation()`, which will execute the Mutation and return a `MutationPromise`
- Using an action shortcut function, which returns a `MutationPromise`
  - Calling the action shortcut function will execute the Mutation and return a `MutationPromise`

The following is true for both the action shortcut function and the `MutationRef` function:
- The `MutationPromise` returned will resolve to the result of the Mutation once it has finished executing
- If the Mutation accepts arguments, both the action shortcut function and the `MutationRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Mutation
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `example` connector's generated functions to execute each mutation. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-mutations).

## CreateGoal
You can execute the `CreateGoal` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createGoal(vars: CreateGoalVariables): MutationPromise<CreateGoalData, CreateGoalVariables>;

interface CreateGoalRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateGoalVariables): MutationRef<CreateGoalData, CreateGoalVariables>;
}
export const createGoalRef: CreateGoalRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createGoal(dc: DataConnect, vars: CreateGoalVariables): MutationPromise<CreateGoalData, CreateGoalVariables>;

interface CreateGoalRef {
  ...
  (dc: DataConnect, vars: CreateGoalVariables): MutationRef<CreateGoalData, CreateGoalVariables>;
}
export const createGoalRef: CreateGoalRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createGoalRef:
```typescript
const name = createGoalRef.operationName;
console.log(name);
```

### Variables
The `CreateGoal` mutation requires an argument of type `CreateGoalVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateGoalVariables {
  title: string;
  description?: string | null;
  priority?: string | null;
  status: string;
  targetDate: DateString;
}
```
### Return Type
Recall that executing the `CreateGoal` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateGoalData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateGoalData {
  goal_insert: Goal_Key;
}
```
### Using `CreateGoal`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createGoal, CreateGoalVariables } from '@dataconnect/generated';

// The `CreateGoal` mutation requires an argument of type `CreateGoalVariables`:
const createGoalVars: CreateGoalVariables = {
  title: ..., 
  description: ..., // optional
  priority: ..., // optional
  status: ..., 
  targetDate: ..., 
};

// Call the `createGoal()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createGoal(createGoalVars);
// Variables can be defined inline as well.
const { data } = await createGoal({ title: ..., description: ..., priority: ..., status: ..., targetDate: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createGoal(dataConnect, createGoalVars);

console.log(data.goal_insert);

// Or, you can use the `Promise` API.
createGoal(createGoalVars).then((response) => {
  const data = response.data;
  console.log(data.goal_insert);
});
```

### Using `CreateGoal`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createGoalRef, CreateGoalVariables } from '@dataconnect/generated';

// The `CreateGoal` mutation requires an argument of type `CreateGoalVariables`:
const createGoalVars: CreateGoalVariables = {
  title: ..., 
  description: ..., // optional
  priority: ..., // optional
  status: ..., 
  targetDate: ..., 
};

// Call the `createGoalRef()` function to get a reference to the mutation.
const ref = createGoalRef(createGoalVars);
// Variables can be defined inline as well.
const ref = createGoalRef({ title: ..., description: ..., priority: ..., status: ..., targetDate: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createGoalRef(dataConnect, createGoalVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.goal_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.goal_insert);
});
```

## UpdateTask
You can execute the `UpdateTask` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateTask(vars: UpdateTaskVariables): MutationPromise<UpdateTaskData, UpdateTaskVariables>;

interface UpdateTaskRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateTaskVariables): MutationRef<UpdateTaskData, UpdateTaskVariables>;
}
export const updateTaskRef: UpdateTaskRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateTask(dc: DataConnect, vars: UpdateTaskVariables): MutationPromise<UpdateTaskData, UpdateTaskVariables>;

interface UpdateTaskRef {
  ...
  (dc: DataConnect, vars: UpdateTaskVariables): MutationRef<UpdateTaskData, UpdateTaskVariables>;
}
export const updateTaskRef: UpdateTaskRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateTaskRef:
```typescript
const name = updateTaskRef.operationName;
console.log(name);
```

### Variables
The `UpdateTask` mutation requires an argument of type `UpdateTaskVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateTaskVariables {
  id: UUIDString;
  isCompleted: boolean;
}
```
### Return Type
Recall that executing the `UpdateTask` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateTaskData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateTaskData {
  task_update?: Task_Key | null;
}
```
### Using `UpdateTask`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateTask, UpdateTaskVariables } from '@dataconnect/generated';

// The `UpdateTask` mutation requires an argument of type `UpdateTaskVariables`:
const updateTaskVars: UpdateTaskVariables = {
  id: ..., 
  isCompleted: ..., 
};

// Call the `updateTask()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateTask(updateTaskVars);
// Variables can be defined inline as well.
const { data } = await updateTask({ id: ..., isCompleted: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateTask(dataConnect, updateTaskVars);

console.log(data.task_update);

// Or, you can use the `Promise` API.
updateTask(updateTaskVars).then((response) => {
  const data = response.data;
  console.log(data.task_update);
});
```

### Using `UpdateTask`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateTaskRef, UpdateTaskVariables } from '@dataconnect/generated';

// The `UpdateTask` mutation requires an argument of type `UpdateTaskVariables`:
const updateTaskVars: UpdateTaskVariables = {
  id: ..., 
  isCompleted: ..., 
};

// Call the `updateTaskRef()` function to get a reference to the mutation.
const ref = updateTaskRef(updateTaskVars);
// Variables can be defined inline as well.
const ref = updateTaskRef({ id: ..., isCompleted: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateTaskRef(dataConnect, updateTaskVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.task_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.task_update);
});
```

## CreateUser
You can execute the `CreateUser` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createUser(vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;

interface CreateUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
}
export const createUserRef: CreateUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createUser(dc: DataConnect, vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;

interface CreateUserRef {
  ...
  (dc: DataConnect, vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
}
export const createUserRef: CreateUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createUserRef:
```typescript
const name = createUserRef.operationName;
console.log(name);
```

### Variables
The `CreateUser` mutation requires an argument of type `CreateUserVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateUserVariables {
  displayName: string;
  email?: string | null;
}
```
### Return Type
Recall that executing the `CreateUser` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateUserData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateUserData {
  user_insert: User_Key;
}
```
### Using `CreateUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createUser, CreateUserVariables } from '@dataconnect/generated';

// The `CreateUser` mutation requires an argument of type `CreateUserVariables`:
const createUserVars: CreateUserVariables = {
  displayName: ..., 
  email: ..., // optional
};

// Call the `createUser()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createUser(createUserVars);
// Variables can be defined inline as well.
const { data } = await createUser({ displayName: ..., email: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createUser(dataConnect, createUserVars);

console.log(data.user_insert);

// Or, you can use the `Promise` API.
createUser(createUserVars).then((response) => {
  const data = response.data;
  console.log(data.user_insert);
});
```

### Using `CreateUser`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createUserRef, CreateUserVariables } from '@dataconnect/generated';

// The `CreateUser` mutation requires an argument of type `CreateUserVariables`:
const createUserVars: CreateUserVariables = {
  displayName: ..., 
  email: ..., // optional
};

// Call the `createUserRef()` function to get a reference to the mutation.
const ref = createUserRef(createUserVars);
// Variables can be defined inline as well.
const ref = createUserRef({ displayName: ..., email: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createUserRef(dataConnect, createUserVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.user_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.user_insert);
});
```

