import { ConnectorConfig, DataConnect, QueryRef, QueryPromise, MutationRef, MutationPromise } from 'firebase/data-connect';

export const connectorConfig: ConnectorConfig;

export type TimestampString = string;
export type UUIDString = string;
export type Int64String = string;
export type DateString = string;




export interface CreateGoalData {
  goal_insert: Goal_Key;
}

export interface CreateGoalVariables {
  title: string;
  description?: string | null;
  priority?: string | null;
  status: string;
  targetDate: DateString;
}

export interface CreateUserData {
  user_insert: User_Key;
}

export interface CreateUserVariables {
  displayName: string;
  email?: string | null;
}

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

export interface Goal_Key {
  id: UUIDString;
  __typename?: 'Goal_Key';
}

export interface Reminder_Key {
  id: UUIDString;
  __typename?: 'Reminder_Key';
}

export interface Task_Key {
  id: UUIDString;
  __typename?: 'Task_Key';
}

export interface UpdateTaskData {
  task_update?: Task_Key | null;
}

export interface UpdateTaskVariables {
  id: UUIDString;
  isCompleted: boolean;
}

export interface User_Key {
  id: UUIDString;
  __typename?: 'User_Key';
}

interface CreateGoalRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateGoalVariables): MutationRef<CreateGoalData, CreateGoalVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateGoalVariables): MutationRef<CreateGoalData, CreateGoalVariables>;
  operationName: string;
}
export const createGoalRef: CreateGoalRef;

export function createGoal(vars: CreateGoalVariables): MutationPromise<CreateGoalData, CreateGoalVariables>;
export function createGoal(dc: DataConnect, vars: CreateGoalVariables): MutationPromise<CreateGoalData, CreateGoalVariables>;

interface GetGoalsRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetGoalsData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<GetGoalsData, undefined>;
  operationName: string;
}
export const getGoalsRef: GetGoalsRef;

export function getGoals(): QueryPromise<GetGoalsData, undefined>;
export function getGoals(dc: DataConnect): QueryPromise<GetGoalsData, undefined>;

interface UpdateTaskRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateTaskVariables): MutationRef<UpdateTaskData, UpdateTaskVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateTaskVariables): MutationRef<UpdateTaskData, UpdateTaskVariables>;
  operationName: string;
}
export const updateTaskRef: UpdateTaskRef;

export function updateTask(vars: UpdateTaskVariables): MutationPromise<UpdateTaskData, UpdateTaskVariables>;
export function updateTask(dc: DataConnect, vars: UpdateTaskVariables): MutationPromise<UpdateTaskData, UpdateTaskVariables>;

interface CreateUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
  operationName: string;
}
export const createUserRef: CreateUserRef;

export function createUser(vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;
export function createUser(dc: DataConnect, vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;

