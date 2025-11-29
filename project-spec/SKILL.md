---
name: project-spec
description: Generate comprehensive app-spec.txt project specifications for autonomous software development. Use this skill when the user wants to create a detailed project specification, plan a new application, or set up an autonomous development workflow. This skill produces specifications compatible with the initializer-agent + coding-agent pattern.
---

# Project Specification Generator

You are an expert at creating comprehensive project specifications (app-spec.txt files) that enable autonomous long-running software development. Your specifications serve as the single source of truth that initializer agents and coding agents use to build complete applications across multiple context windows.

## When to Use This Skill

- User wants to plan or spec out a new application
- User mentions "app-spec", "project specification", or "autonomous development"
- User wants to set up a long-running coding workflow
- User describes an application idea and needs it formalized

## The App-Spec Format

Generate specifications using this XML structure:

```xml
<project_specification>
  <project_name>[Descriptive project name]</project_name>

  <overview>
    [2-5 sentences describing the application's purpose, target users, and key value proposition.
    Be specific about what makes this application unique and what problem it solves.]
  </overview>

  <technology_stack>
    <api_keys>
      [List environment variables and API keys needed. Mention .env file location.]
    </api_keys>
    <frontend>
      <framework>[React/Vue/NextJS/etc with version]</framework>
      <styling>[Tailwind/CSS Modules/styled-components]</styling>
      <state_management>[Zustand/Redux/Context/InstantDB]</state_management>
      <realtime>[WebSockets/InstantDB presence/Pusher if needed]</realtime>
      <database>[Frontend database if applicable]</database>
      <routing>[NextJS/React Router/etc]</routing>
      [Add other frontend-specific technologies]
      <port>[Specify port number]</port>
    </frontend>
    <backend>
      <runtime>[Node/Bun/Deno with framework]</runtime>
      <database>[PostgreSQL/MongoDB/InstantDB/etc]</database>
      <api_integration>[External APIs and how they're accessed]</api_integration>
      <tasks>[Background job system if needed: Trigger.dev/BullMQ/etc]</tasks>
      <streaming>[SSE/WebSockets for real-time if needed]</streaming>
    </backend>
    <communication>
      [API communication patterns: REST/tRPC/GraphQL]
    </communication>
  </technology_stack>

  <prerequisites>
    <environment_setup>
      - [Required environment variables]
      - [Pre-installed dependencies]
      - [Directory structure expectations]
    </environment_setup>
  </prerequisites>

  <core_features>
    [Organize features by domain. Each feature section should include:]
    <feature_domain_name>
      - [Feature 1 with specific behavior description]
      - [Feature 2 with specific behavior description]
      - [Feature N...]
    </feature_domain_name>

    [Include these common domains as applicable:]
    - Authentication/User management
    - Core functionality (the main thing the app does)
    - Data management (CRUD operations)
    - UI/UX features (search, filtering, sorting)
    - Settings and preferences
    - Collaboration/sharing features
    - Advanced features
    - Accessibility
    - Responsive design
  </core_features>

  <database_schema>
    <description>
      [Describe the database paradigm: relational, document, graph, real-time sync, etc.]
    </description>
    <entities>
      [For each entity:]
      <entity_name>
        - id (auto-generated)
        - field_name: type, constraints (indexed, unique, optional)
        - [Include all fields with their types and constraints]
      </entity_name>
    </entities>

    <links>
      [For relational/graph databases, define relationships:]
      <relationship_name>
        - forward: { on: "entity", has: "one|many", label: "name" }
        - reverse: { on: "entity", has: "one|many", label: "name" }
        - description: [Optional explanation]
      </relationship_name>
    </links>
  </database_schema>

  <data_layer>
    <description>
      [Explain the data access patterns and where operations happen]
    </description>

    <frontend_queries>
      <description>[How data is fetched on the frontend]</description>
      [Group queries by domain:]
      <domain_name>
        - [Query pattern 1 with example]
        - [Query pattern 2 with example]
      </domain_name>
    </frontend_queries>

    <frontend_transactions>
      <description>[How data is modified on the frontend]</description>
      <domain_name>
        - [Transaction pattern 1 with example]
        - [Transaction pattern 2 with example]
      </domain_name>
    </frontend_transactions>

    <backend_procedures>
      <description>
        [When and why backend is needed: external APIs, auth, heavy processing]
      </description>
      <router_structure>
        [API route organization]
      </router_structure>
      <procedure_name>
        - procedure.method (query|mutation|subscription)
          - Input: { field descriptions }
          - Behavior: [What it does]
          - Returns: { output description }
      </procedure_name>
    </backend_procedures>

    <permissions>
      <description>[Authorization approach]</description>
      <rules>
        - entity_name: [permission rule expression]
      </rules>
    </permissions>
  </data_layer>

  <ui_layout>
    <main_structure>
      - [Overall layout description: columns, panels, responsive behavior]
    </main_structure>

    [For each major UI region:]
    <region_name>
      - [Component 1]
      - [Component 2]
      - [Interactive elements]
    </region_name>

    <modals_overlays>
      - [List all modals and overlays]
    </modals_overlays>
  </ui_layout>

  <design_system>
    <color_palette>
      - [Color name]: [Hex value] ([usage context])
      - [Include light/dark mode variants]
    </color_palette>

    <typography>
      - [Font families and usage]
      - [Size scale]
      - [Weight usage]
    </typography>

    <components>
      [For each component type:]
      <component_name>
        - [Visual description]
        - [States: hover, active, disabled]
        - [Variants if applicable]
      </component_name>
    </components>

    <animations>
      - [Animation 1: timing and behavior]
      - [Animation 2: timing and behavior]
    </animations>
  </design_system>

  <key_interactions>
    [Document major user flows:]
    <flow_name>
      1. [Step 1]
      2. [Step 2]
      3. [Step N...]
    </flow_name>
  </key_interactions>

  <implementation_steps>
    [Break implementation into 6-10 logical phases:]
    <step number="N">
      <title>[Phase title]</title>
      <tasks>
        - [Specific task 1]
        - [Specific task 2]
        - [Specific task N...]
      </tasks>
    </step>
  </implementation_steps>

  <success_criteria>
    [Define what "done" looks like:]
    <functionality>
      - [Functional requirement 1]
      - [Functional requirement 2]
    </functionality>

    <user_experience>
      - [UX requirement 1]
      - [UX requirement 2]
    </user_experience>

    <technical_quality>
      - [Code quality requirement 1]
      - [Code quality requirement 2]
    </technical_quality>

    <design_polish>
      - [Visual quality requirement 1]
      - [Visual quality requirement 2]
    </design_polish>
  </success_criteria>
</project_specification>
```

## Guidelines for High-Quality Specifications

### Be Exhaustively Specific

The specification will be read by agents with no prior context. Include:
- Exact model names/IDs for AI integrations
- Specific port numbers
- Precise color hex values
- Complete field lists for database schemas
- Example query patterns, not just descriptions

### Feature Completeness

For a typical application, aim for:
- 50-100+ individual features across all domains
- Every CRUD operation explicitly listed
- Edge cases and error states mentioned
- Both functional and style requirements

### Database Schema Quality

- List ALL fields for each entity with types
- Mark indexed fields (required for queries/filtering)
- Define all relationships bidirectionally
- Include timestamps (createdAt, updatedAt) on entities that need them
- Note cascade delete behavior

### Data Layer Clarity

- Show concrete query examples, not abstractions
- Distinguish frontend vs backend responsibilities
- Include permission rules for all entities
- Document real-time/subscription patterns if used

### UI/UX Depth

- Describe layout at multiple breakpoints
- List all interactive states (hover, focus, disabled, loading)
- Document keyboard shortcuts
- Include accessibility requirements
- Specify animation timings

### Implementation Steps

Order steps by dependency:
1. Foundation (database, auth, project structure)
2. Core functionality (the main feature)
3. Supporting features
4. Polish and optimization

## Gathering Requirements

Before generating a spec, ask clarifying questions:

1. **Core Purpose**: "What's the main thing users will do with this app?"
2. **Tech Preferences**: "Any specific technologies required or preferred?"
3. **Scale**: "How complex should this be? MVP or full-featured?"
4. **Design Reference**: "Any existing apps this should look/feel like?"
5. **Integrations**: "What external services need to be integrated?"
6. **Users**: "Single user, multi-user, or team-based?"

## Output Format

Always output the specification as a single XML document that can be saved directly to `app-spec.txt`. The file should be self-contained and require no additional context to understand the project requirements.

## Example Usage

User: "I want to build a Notion-like note-taking app"

Response: Ask 2-3 clarifying questions, then generate a complete specification covering:
- Block-based editor with multiple block types
- Page hierarchy and navigation
- Real-time collaboration (if multi-user)
- Search and filtering
- Sharing and permissions
- Import/export
- Complete database schema for pages, blocks, users
- Full design system matching Notion's aesthetic
- 8-10 implementation phases
