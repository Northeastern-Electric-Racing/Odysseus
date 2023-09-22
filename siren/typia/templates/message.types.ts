import typia from "typia";
import { SubscriptionMessage, ServerMessage } from "../../Odyssey-Base/src/types/message.types";

export type { SubscriptionMessage, ServerMessage};

// Important: Do not use typia top level function checks, as this project is in generation mode due to bun
// Use these reusable const functions only. Also if this project switches to transformation mode, AOT code duplication is possible.
// See more here: https://typia.io/docs/validators/assert/

// TODO: comment out unneeded functions, for now all should stays as many are helpful in debugging

// "strict" means it will check for extra JSON properties that the code will never acces
// Strict isn't necessary but helpful in a debug state.  createIs is the most likely the quickest and smallest for final product

// for SubscriptionMessage

// returns true/false if input is valid SubscriptionMessage
export const checkIsSubscriptionMessage = typia.createIs<SubscriptionMessage>();

// returns true/false if input is a *strictly* valid SubcriptionMessage
export const strictCheckIsSubscriptionMessage = typia.createEquals<SubscriptionMessage>();

// creates a random SubscriptionMessage object
export const makeRandSubscriptionMessage = typia.createRandom<SubscriptionMessage>();

// strictly asserts input is valid SubscriptionMessage, throwing TypeGuardError if wrong
export const strictAssertSubscriptionMessage = typia.createAssertEquals<SubscriptionMessage>();

// strictly validates input, returing a special Validation class which can be parsed for specific errors
export const strictValidateSubscriptionMessage = typia.createValidateEquals<SubscriptionMessage>();

// for ServerMessage

// returns true/false if input is valid SubscriptionMessage
export const checkIsServerMessage = typia.createIs<ServerMessage>();

// returns true/false if input is a *strictly* valid SubcriptionMessage
export const strictCheckIsServerMessage = typia.createEquals<ServerMessage>();

// creates a random SubscriptionMessage object
export const makeRandServerMessage = typia.createRandom<ServerMessage>();

// strictly asserts input is valid SubscriptionMessage, throwing TypeGuardError if wrong
export const strictAssertServerMessage = typia.createAssertEquals<ServerMessage>();

// strictly validates input, returing a special Validation class which can be parsed for specific errors
export const strictValidateServerMessage = typia.createValidateEquals<ServerMessage>();




