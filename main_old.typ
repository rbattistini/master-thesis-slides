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
  footer-subtitle: "Giovanni Ciatto, Gianluca Aguzzi, Riccardo Battistini",
)

= Introduction

== Goal of the thesis

Traditional BDI programming frameworks typically lack mechanisms allowing agents to autonomously acquire or build new plans at runtime.

The procedural behavior of AgentSpeak(L) agents is then limited to scenarios where the agent behavior can be suitably defined at design time (pre-programmed): an effective option in terms of computational efficiency, which however constrains agent flexibility, responsiveness, and overall autonomy when facing unpredictable environments.

Extending BDI agents with planning capabilities has thus been extensively explored.

== LLM-based plan generation for BDI agents

This work enhances BDI agents with autonomous plan generation using Generative AI.

== Research Questions
#set enum(numbering: "RQ1.")

#enum(
  tight: false,
  spacing: 2em,
[What information would LLMs require to generate BDI plans?],
[How should knowledge be transferred between LLMs and BDI agents?],
[How does automatic plan generation impact BDI agents operation and specification?],
[Can LLMs generate reusable BDI plans?],
)

= Background

== JaKtA: Jason-like Kotlin Agents

JaKtA was chosen due to several practical advantages:

#list(
  tight: false,
  [
    Internal DSL for BDI agents in Kotlin
      - Native implementation without external domain-specific languages
  ],
  [
    Modern language features integration
      - Leverages null safety, coroutines, and functional programming
  ],
  [
    Multi-paradigm programming support
      - Combines agent-oriented programming with other paradigms seamlessly
  ],
  [
    Full JVM ecosystem access
      - Complete IDE support with autocompletion, debugging, and build system integration
  ],
)

== Plan generation in BDI agents

#lorem(20)

= Design

== The structure of the generative process

/ *Plan Generation Procedure* (PGP): A generative process that allows an agent to dynamically synthesize actionable plans tailored to specific goals. The resulting plans can then be incorporated in the plan library and be invoked.

A PGP involves:

+ encoding the agent's current cognitive state and operational context into a structured prompt comprehensible to the LLM;
+ parsing the LLM output to extract the generated plans.

== Triggering the PGP

Two approaches to trigger a PGP have been implemented.

#list(
  [*On-demand PGP*
    - modelled as an action that the agent can invoke whenever it needs to generate a plan;
    - the agent's programmer decides when the agent should trigger the PGP;
    - the PGP may generate plans that use the action in their body, so generated plans may themselves trigger the PGP to generate new plans, when executed.
  ],
  [*Reactive PGP*
    - it is implicitly triggered by the agent's control loop whenever an event `E` occurs and the agent has no relevant plan for it, preventing the current intention from failing;
    - if the PGP fails, the current intention fails;
    - if the PGP succeeds, the agent would keep on executing its intention as if the plan was already available from start.
  ],
)

== Knowledge exchange of a BDI Agent with an LLM

The minimal set of relevant information to build the prompt:

#enum(
  tight: false,
  [+ the goal G for which the plans are needed and the request to generate plans for it;],
  [+ the goals, actions, and beliefs which are already known to the agent;],
  [+ the current plans, goals, and beliefs of the agent;],
  [+ the intended outcome of the PGP;],
  [+ the AgentSpeak(L) syntax and its intended meaning;],
  [+ how to impersonate a BDI agent willing to generate a plan;],
  [+ what a BDI agent is in the first place;],
  [+ the syntax the LLM should use to encode its responses.],
)

= Implementation

== Generative process pipeline

#lorem(20)

== Generative agent specification

#grid(
  columns: (1.2fr, 1.6fr),
  gutter: 1em,
  [
    Writing the specification requires:

    + Defining a prompt template or use the built-in ones.
    + Choosing the generation strategy and the scope to which applies.
    + Implementing custom filters or use the built-in ones.
    + Writing natural language documentation, which comprises hints and remarks.
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
    Example use of the `.meaning` function to document a fact.
  ],
)

= Evaluation

== The explorer robot example

#columns(3)[
  #image("assets/world.svg", height: 4.5cm)
  #colbreak()
  #image("assets/directions.svg", height: 4.5cm)
  #colbreak()
  ```prolog
  direction(north).
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
  ```
]

== Experimental results

#columns(1)[
  - LLMs: Claude Sonnet 4, Deepseek V3 Chat, GPT 4.1 and Gemini 2.5 Flash
  - Prompting configurations: No Hints, Only Hints, Hints and Remarks
  - Temperature values: 0.1, 0.5 and 0.9
  - Ten queries per configuration, for a total of 360 experimental runs.

  #set align(center)
  #table(
    columns: 4,
    [*Model*], [*Prompt Type*], [*Temperature*], [*Task Success Rate* (%)],
    [GPT 4.1], [Hints and Remarks], [0.1], [100.00],
    [Deepseek Chat V3], [Hints and Remarks], [0.1], [100.00],
    [Deepseek Chat V3], [Hints and Remarks], [0.5], [100.00],
    [GPT 4.1], [Only Hints], [0.1], [90.00],
    [Deepseek Chat V3], [Only Hints], [0.1], [88.89],
    [Claude Sonnet 4], [Hints and Remarks], [0.5], [77.78],
  )
  #colbreak()
  #set align(left)
  #columns(2)[
    #image("assets/plot.svg", height: 4.5cm)
    Claude and Gemini prefer a temperature that is not either too high or too low. GPT 4.1 and Deepseek work better as the temperature value lowers.
    #colbreak()
    #image("assets/plot.svg", height: 4.5cm)

  ]
]

= Conclusion

== Addressing the Research Questions
#set enum(numbering: "RQ1.")

This work systematically addresses four key questions:

#enum(
  tight: false,
  [
    *What information do LLMs need for BDI plan generation?*
      - Structured prompts with goals, beliefs, actions, and BDI operational semantics
  ],
  [
    *How to transfer knowledge between LLMs and BDI agents?*
      - Structured prompts with parsable outputs for reliable plan integration
  ],
  [
    *How does automatic generation impact BDI operation?*
      - Shifts from exhaustive plan encoding to basic domain knowledge provision
  ],
  [
    *Can LLMs generate reusable BDI plans?*
      - Shows promise for general, variable-based plans despite performance variability
  ],
)

== Future Works

Exploring runtime validation and verification mechanisms to address hallucinations or inaccuracies in LLM-generated constructs.

Plan repair and refinement mechanisms, experimentation with different structured output formats, enhanced modularization of BDI agent cycles, integration with the Model Context Protocol, finetuning and use of artifacts.

Additionally, studying prompt robustness under varying conditions and developer inaccuracies could enhance the methodology's practicality.

Ablation studies may clarify factors influencing prompt effectiveness (RQ1) and knowledge transfer (RQ2).

Testing scenarios with concurrent goals, dynamic environments, and partial observability will validate scalability and generalization (RQ4).
