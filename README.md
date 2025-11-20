# PriestPower

**PriestPower** is a World of Warcraft (1.12) addon designed to manage the "Proclaim Champion" ability for Priests on Turtle WoW. It allows Raid Leaders and Class Leads to assign specific champions to each priest and specify which follow-up buff (Empower, Grace, or Bond) they should maintain.

## Features

*   **Raid/Party Assignments**: Assign a target "Champion" for each priest in your group.
*   **Buff Management**: Specify which secondary buff (Empower, Grace, Bond) the priest should keep on their champion.
*   **One-Button Casting**: A small, movable status frame shows your assignment and allows you to cast the correct spell (Proclaim or the specific Buff) with a single click.
*   **Syncing**: Assignments are automatically synced between all addon users in the raid/party.

## Usage

### Opening the Menu
Type `/prp` or `/priestpower` in the chat to open the main assignment window.

### Making Assignments
1.  Open the main window (`/prp`).
2.  Find the priest you want to assign in the list.
3.  Use the first dropdown to select their **Champion** (the player they will buff).
4.  Use the second dropdown to select the **Buff** they should maintain (Empower, Grace, or Bond).
5.  The assignment is immediately sent to that priest and all other addon users.

### Reporting Assignments
Type `/prp print` to output the current list of assignments to the group chat (Raid or Party).
*   If you are in a Raid, it sends to **RAID**.
*   If you are in a Party, it sends to **PARTY**.
*   If you are solo, it prints to your local chat window.

This is useful for sharing the plan with players who do not have the addon installed.

### The Status Frame
Once you are assigned a Champion, a small icon will appear on your screen.

*   **Visual Status**:
    *   **Red**: Your Champion does not have "Proclaim Champion".
    *   **Yellow**: Your Champion has "Proclaim Champion" but is missing the assigned secondary buff.
    *   **Green**: Your Champion is fully buffed.
    *   **Grey**: Your Champion is out of range or offline.
*   **Casting**: simply **Left Click** the icon to cast the missing spell. It will smart-cast "Proclaim Champion" first if missing, then your assigned buff.
*   **Moving**: Hold **Ctrl + Left Click** and drag to move the frame to your desired location.

## Upcoming Features
*   **Permissions**: Raid Leader/Assistant only mode for making assignments.
*   **Timers**: Visual timer showing the remaining duration of the assigned buff.
