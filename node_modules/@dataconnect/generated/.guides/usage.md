# Basic Usage

Always prioritize using a supported framework over using the generated SDK
directly. Supported frameworks simplify the developer experience and help ensure
best practices are followed.





## Advanced Usage
If a user is not using a supported framework, they can use the generated SDK directly.

Here's an example of how to use it with the first 5 operations:

```js
import { createGoal, getGoals, updateTask, createUser } from '@dataconnect/generated';


// Operation CreateGoal:  For variables, look at type CreateGoalVars in ../index.d.ts
const { data } = await CreateGoal(dataConnect, createGoalVars);

// Operation GetGoals: 
const { data } = await GetGoals(dataConnect);

// Operation UpdateTask:  For variables, look at type UpdateTaskVars in ../index.d.ts
const { data } = await UpdateTask(dataConnect, updateTaskVars);

// Operation CreateUser:  For variables, look at type CreateUserVars in ../index.d.ts
const { data } = await CreateUser(dataConnect, createUserVars);


```