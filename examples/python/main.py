#!/usr/bin/env python3
"""
Simple Python example for testing the MCP Language Server with Python support.
This module demonstrates basic Python features that language servers can analyze.
"""

import sys
from typing import List, Optional, Dict, Any
from dataclasses import dataclass
from enum import Enum


class Priority(Enum):
    """Priority levels for tasks."""
    LOW = 1
    MEDIUM = 2
    HIGH = 3


@dataclass
class Task:
    """A simple task with priority and completion status."""
    title: str
    description: str = ""
    priority: Priority = Priority.MEDIUM
    completed: bool = False

    def mark_completed(self) -> None:
        """Mark this task as completed."""
        self.completed = True

    def __str__(self) -> str:
        status = "✓" if self.completed else "○"
        return f"{status} [{self.priority.name}] {self.title}"


class TaskManager:
    """Manages a collection of tasks."""

    def __init__(self) -> None:
        self._tasks: List[Task] = []
        self._next_id = 1

    def add_task(self, title: str, description: str = "",
                 priority: Priority = Priority.MEDIUM) -> Task:
        """Add a new task to the manager.

        Args:
            title: The task title
            description: Optional task description
            priority: Task priority level

        Returns:
            The created task
        """
        task = Task(title=title, description=description, priority=priority)
        self._tasks.append(task)
        return task

    def get_tasks(self, completed: Optional[bool] = None) -> List[Task]:
        """Get tasks, optionally filtered by completion status.

        Args:
            completed: If None, return all tasks. If True/False, filter by status.

        Returns:
            List of matching tasks
        """
        if completed is None:
            return self._tasks.copy()
        return [task for task in self._tasks if task.completed == completed]

    def complete_task(self, title: str) -> bool:
        """Mark a task as completed by title.

        Args:
            title: The title of the task to complete

        Returns:
            True if task was found and completed, False otherwise
        """
        for task in self._tasks:
            if task.title == title and not task.completed:
                task.mark_completed()
                return True
        return False

    def get_stats(self) -> Dict[str, Any]:
        """Get statistics about tasks.

        Returns:
            Dictionary with task statistics
        """
        total = len(self._tasks)
        completed = len([t for t in self._tasks if t.completed])
        pending = total - completed

        priority_counts = {p.name: 0 for p in Priority}
        for task in self._tasks:
            if not task.completed:
                priority_counts[task.priority.name] += 1

        return {
            "total": total,
            "completed": completed,
            "pending": pending,
            "completion_rate": completed / total if total > 0 else 0.0,
            "pending_by_priority": priority_counts
        }

    def __len__(self) -> int:
        return len(self._tasks)

    def __str__(self) -> str:
        if not self._tasks:
            return "No tasks"

        lines = ["Tasks:"]
        for task in self._tasks:
            lines.append(f"  {task}")

        stats = self.get_stats()
        lines.append(f"\nStats: {stats['completed']}/{stats['total']} completed "
                    f"({stats['completion_rate']:.1%})")

        return "\n".join(lines)


def demo_task_manager() -> None:
    """Demonstrate the task manager functionality."""
    print("=== MCP Language Server Python Demo ===\n")

    # Create task manager
    manager = TaskManager()

    # Add some tasks
    manager.add_task("Set up Docker environment",
                    "Build and test the mcp-language-server Docker image",
                    Priority.HIGH)

    manager.add_task("Write documentation",
                    "Update README with Docker examples",
                    Priority.MEDIUM)

    manager.add_task("Test language servers",
                    "Verify Java, Python, and Rust language servers work",
                    Priority.HIGH)

    manager.add_task("Create example projects",
                    "Add sample code for testing",
                    Priority.LOW)

    # Show initial state
    print("Initial tasks:")
    print(manager)
    print()

    # Complete some tasks
    print("Completing some tasks...")
    manager.complete_task("Set up Docker environment")
    manager.complete_task("Create example projects")
    print()

    # Show updated state
    print("Updated tasks:")
    print(manager)
    print()

    # Show detailed stats
    stats = manager.get_stats()
    print("Detailed statistics:")
    for key, value in stats.items():
        print(f"  {key}: {value}")


def main() -> int:
    """Main entry point."""
    try:
        demo_task_manager()
        return 0
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
