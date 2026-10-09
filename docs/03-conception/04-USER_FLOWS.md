# Conception 04. User flows

## 1. Onboarding a student and their parent

```mermaid
flowchart TD
    A["Teacher: + Élève"] --> B["Form: student + parent(s) + groups"]
    B --> C["Server creates accounts<br/>temporary passwords"]
    C --> D["Card with login details<br/>Copier le message"]
    D --> E["Teacher sends it on WhatsApp or paper"]
    E --> F["Student / parent logs in"]
    F --> G{"First login?"}
    G -- yes --> H["Choose a new password (S)"]
    G -- no --> I["Role home screen"]
    H --> I
```

## 2. The teacher's day

```mermaid
flowchart TD
    A["Open app"] --> B["Ma journée"]
    B --> C{"Session soon?"}
    C -- yes --> D["Démarrer la séance"]
    D --> E["Session mode:<br/>attendance, content, notes, Meet"]
    E --> F["Terminer la séance:<br/>covered, note, homework?"]
    F --> B
    C -- no --> G{"Items in À corriger?"}
    G -- yes --> H["Correction screen<br/>Enregistrer et suivant"]
    H --> B
    G -- no --> I["Prepare: Contenus,<br/>build or upload, share, assign"]
    I --> B
```

## 3. Upload an existing series and assign it

```mermaid
flowchart LR
    A["Importer un document<br/>or camera scan"] --> B["Title, chapter,<br/>tag Série"]
    B --> C["Library item (published)"]
    C --> D["Assigner"]
    D --> E["Group, deadline,<br/>mode Fichier"]
    E --> F["Students notified<br/>status À faire"]
```

## 4. Assignment lifecycle

```mermaid
sequenceDiagram
    actor T as Teacher
    participant App as NextGeneration Class
    actor S as Student
    actor P as Parent

    T->>App: Assign "Série 02" to Groupe A, deadline Friday 18:00
    App->>S: Push "Nouveau devoir : Série 02"
    App->>S: Push 24 h before the deadline (if not submitted)
    S->>App: Photos of paper work, Envoyer
    App->>T: Item in À corriger (+ morning digest)
    T->>App: Score 15/20, comment, Enregistrer et suivant
    App->>S: Push "Devoir corrigé : 15/20"
    App->>P: New grade in the overview
    Note over App: At the deadline, students without a submission become Manquant
    App->>P: Push "Devoir manquant : Série 02"
```

## 5. Quiz: build, assign, take, correct

```mermaid
flowchart TD
    A["+ Quiz or + QCM"] --> B["Questions with formulas"]
    B --> C["Aperçu élève"]
    C --> D{"OK?"}
    D -- no --> B
    D -- yes --> E["Publier"]
    E --> F["Assigner: group, deadline, mode En ligne"]
    F --> G["Student takes the quiz<br/>answers saved as they go"]
    G --> H["Submit or timer ends"]
    H --> I["Automatic score"]
    I --> J{"Open questions?"}
    J -- no --> K["Corrigé, grade visible"]
    J -- yes --> L["À corriger with partial score"]
    L --> M["Teacher scores open answers"]
    M --> K
```

## 6. Recurring session change

```mermaid
flowchart TD
    A["Teacher edits Tuesday 17:00 session"] --> B{"Scope?"}
    B -- "Cette séance uniquement" --> C["Session marked as exception<br/>other sessions unchanged"]
    B -- "Cette séance et les suivantes" --> D["Old rule ends<br/>new rule from this date<br/>future sessions regenerated"]
    C & D --> E["Students and parents notified<br/>if date or time changed"]
```

## 7. Parent check

```mermaid
flowchart LR
    A["Push: Absence / Devoir manquant / Nouvelle note"] --> B["Aperçu of the child"]
    B --> C["Subject card"]
    C --> D["Details: assignments,<br/>grades, comments, attendance"]
```
