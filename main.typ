#import "lib.typ": *
#let titleColor = blue.darken(60%)
#show: slides.with(
  title: "Exploiting GenAI for Plan\n Generation in BDI Agents",
  date: "10.07.2025",
  authors: "Riccardo Battistini",
  ratio: 16 / 9,
  layout: "small",
  title-color: titleColor,
  toc: false,
  count: "number",
  footer-title: "Exploiting GenAI for Plan Generation in BDI Agents",
  footer-subtitle: "Laurea Magistrale in Ingegneria e Scienze Informatiche",
)

= Introduction

== Goal of the thesis

This work proposes a novel framework that extends the AgentSpeak(L) reasoning cycle with generative capabilities, enabling agents to synthesize plans on-the-fly.

This framework:
- preserves the strengths of the BDI model;
  - theoretical foundation;
  - programming paradigm;
  - verifiable reasoning;
- augments the existing BDI agents rather than replacing them;
  - unlike LLM agents, they are not fully generative and language-driven.

== Research Questions

Given the goal of augmenting BDI agents with autonomous plan generation capabilities using LLMs, the following research questions have been identified.

#enum(
  tight: false,
  numbering: "RQ1.",
[What information would LLMs require to generate BDI plans?],
[How should knowledge be transferred between LLMs and BDI agents?],
[How does automatic plan generation impact BDI agents operation and specification?],
[Can LLMs generate reusable BDI plans?],
)

= Background

== Past Solutions for Plan Generation in BDI Agents

- In AgentSpeak(L) the behavior of an agent is defined at design time by the developer;
  - usually actions' preconditions and effects are not encoded.

- Past solutions involved using first-principle planners, like STRIPS;
  - *actions* are defined by preconditions and effects;
  - a *plan* is a sequence of actions from an initial state to a goal;
  - the *state* is expressed as a set of fluents (logic facts);
  - the *goal* is defined as a set of predicates.

- They require mapping first-principle planning to the BDI model;
  - *actions* are named procedures that create side-effects;
  - a *plan* has a trigger, a guard and a body;
  - the *state* is expressed as a set of beliefs;
  - the *goal* is the name of something to achieve.

= Contribution

== The Generative Process

/ *Plan Generation Procedure* (PGP): A generative process that allows an agent to dynamically generate plans tailored to specific goals. The resulting plans can then be incorporated in the plan library and be invoked.

A PGP involves:

+ encoding the agent's current state into a structured prompt comprehensible to the LLM;
+ parsing the LLM output to extract the generated plans.

The PGP is modelled as a new action `generate_plan(G)` that the agent can invoke whenever it needs to generate a plan for a given goal `G`.

== When to trigger the PGP?

The PGP can be triggered in two ways.

#list(
  [*On-demand PGP*
    - the agent's programmer decides when the agent should trigger the PGP;
  ],
  [*Reactive PGP*
    - it is implicitly triggered by the agent's control loop whenever an event `E` occurs and the agent has no relevant plan for it, preventing the current intention from failing.
  ],
)

Either way, the PGP may generate plans that use `generate_plan(G)` in their body or invent new subgoals for which no plans exist, so generated plans may themselves trigger a new PGP to generate additional plans, when executed.

== Knowledge exchange of a BDI Agent with an LLM

The minimal set of relevant information to build the prompt that was identified is:

#enum(
  tight: true,
  [+ the goal G for which the plans are needed and the request to generate plans for it;],
  [+ the goals, actions, and beliefs which are already known to the agent;],
  [+ the current plans, goals, and beliefs of the agent;],
  [+ the intended outcome of the PGP;],
  [+ the AgentSpeak(L) syntax and its intended meaning;],
  [+ how to impersonate a BDI agent willing to generate a plan;],
  [+ what a BDI agent is in the first place;],
  [+ the syntax the LLM should use to encode its responses.],
)

== Writing Generative BDI Agent Specifications

#grid(
  columns: (1.2fr, 1.6fr),
  gutter: 1em,
  [
    The programmer configures the generation process and describes the plans, rather than encode them, by:
    
    + defining a prompt template;
    + choosing the generation strategy;
    + selecting only the most relevant information with filters;
    + writing natural language documentation.

    The syntax is extended to allow describing beliefs, goals, actions and plans.
  ],
  [
    ```kt
    agent("ExplorerBot") {
      beliefs {
        admissible {
          +fact {
            "obstacle"("Direction")
          }.meaning {
            "there is an $functor to the ${args[0]}"
          }
        }
      }
    }
    ```
    Example in JaKtA that uses the `.meaning` function to provide a hint on a fact.
  ],
)

= Evaluation

== The Explorer Robot Example

#columns(1)[
#grid(
  columns: (1.2fr, 1.65fr),
  gutter: 1em,
  [
  #set align(center)
  #image("assets/world.svg", height: 4.1cm)
  #set align(left)
  The environment is a gridworld which contains objects, obstacles and a robot. The robot has the objective of reaching the home object.
  ],[
  #raw(
"direction(north).
object(house).
object(box).
free(north).
free(north_west).
free(north_east).
free(west).
free(east).
obstacle(south).
obstacle(south_west).
obstacle(south_east).
there_is(box, north_east).

!reach(home).

-G : missing_plan_for(G) <- generate_plan(G); !G.",
   lang: "Jason",
   block: true,
   syntaxes: "assets/Jason.sublime-syntax",
   theme: "assets/Jason.tmTheme",
)
])
]

== Experimental Setup

- Framework
  - JaKtA, a modern BDI technology based on Kotlin
- Four LLMs
  - Claude Sonnet 4, Deepseek V3 Chat, GPT 4.1 and Gemini 2.5 Flash
- Three prompting configurations
  - No Hints, Only Hints, Hints and Remarks
- Three temperature values
  - 0.1, 0.5 and 0.9
- Ten attempts per configuration
  - 360 experimental runs in total

== Experimental Metrics

- *Task Success Rate (TSR)*
  - Did the robot successfully reach home?
- *Plan/Context Complexity (PC/CC)*
  - How many plans and conditions were generated?
- *Generalization Count (GC)*
  - How many plans used variables?
- *Novelty (NGC/NBC)*
  - Did the LLM invent new goals/beliefs?
- *Semantic Alignment (GSA/BSA)*
  - Did the LLM use existing concepts correctly?
- *Plan-Reference Alignment Score (PRAS)*
  - An LLM-as-judge score comparing generated plans to an expert-designed optimal plan.

== Experimental Results

#columns(1)[
  #set align(center)
  #table(
    columns: 4,
    [*Model*], [*Prompt Type*], [*Temperature*], [*Task Success Rate*],
    [GPT 4.1], [Hints and Remarks], [0.1], [100.00],
    [Deepseek Chat V3], [Hints and Remarks], [0.1], [100.00],
    [Deepseek Chat V3], [Hints and Remarks], [0.5], [100.00],
    [GPT 4.1], [Only Hints], [0.1], [90.00],
    [Deepseek Chat V3], [Only Hints], [0.1], [88.89],
    [Claude Sonnet 4], [Hints and Remarks], [0.5], [77.78],
  )
  #set align(left)
  LLMs are promising for plan generation, provided that appropriate parameter configurations are given and that the agents' programmer documents the domain with hints. 
  Providing remarks significantly improves the results. 

  #colbreak()
  #columns(2)[
    #image("assets/temp-stats.svg", height: 4.5cm)
    Claude and Gemini seem to prefer a temperature that is not either too high or too low. GPT 4.1 and Deepseek work better as the temperature value lowers.
    #colbreak()
    #image("assets/prompt-stats.svg", height: 4.5cm)
    Providing natural-language descriptions is essential for the PGP to work correctly.
  ]
]

= Conclusion

== Addressing the Research Questions

#enum(
  numbering: "RQ1.",
  tight: false,
  [
    *What information would LLMs require to generate BDI plans?*
      - Structured prompts that includes goals, beliefs, actions, and a description of the BDI operational semantics.
  ],
  [
    *How should knowledge be transferred between LLMs and BDI agents?*
      - Structured prompts with parsable outputs, using format-restricting instructions.
  ],
  [
    *How does automatic plan generation impact BDI agents operation and specification?*
      - Shifts from exhaustive plan encoding to domain knowledge provision with natural language.
  ],
  [
    *Can LLMs generate reusable BDI plans?*
      - Shows promise for general, variable-based plans despite performance variability.
  ],
)

== Future Works

#enum(
  tight: false,
[Plan repair and refinement mechanisms
 - with runtime verification mechanism for plan validation and eviction],
[Testing scenarios with partial observability and dynamic environments
 - to evaluate adaptability and generalization],
[Ablation studies for prompt effectiveness under varying conditions
 - different LLM sampling parameters and decoding strategies
 - robustness to developer inaccuracies 
 - different context filtering strategies],
[Different prompt structure and output syntaxes]
)