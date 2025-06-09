package com.example;

/**
 * Simple Java example for testing the MCP Language Server with Java support.
 * This class demonstrates basic Java features that language servers can analyze.
 */
public class Main {

    private static final String GREETING = "Hello from MCP Language Server!";

    private String name;
    private int count;

    public Main(String name) {
        this.name = name;
        this.count = 0;
    }

    /**
     * Gets the current name.
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * Sets a new name.
     * @param name the new name to set
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * Increments the counter and returns the new value.
     * @return the incremented count
     */
    public int incrementCount() {
        return ++count;
    }

    /**
     * Greets the user with a personalized message.
     * @return a greeting message
     */
    public String greet() {
        return String.format("%s Welcome, %s! Count: %d",
                           GREETING, name, count);
    }

    /**
     * Utility method to demonstrate method references and lambda usage.
     * @param items array of strings to process
     * @return processed items
     */
    public static String[] processItems(String[] items) {
        return java.util.Arrays.stream(items)
                .map(String::toUpperCase)
                .filter(s -> !s.isEmpty())
                .toArray(String[]::new);
    }

    public static void main(String[] args) {
        Main example = new Main("Developer");

        System.out.println(example.greet());
        example.incrementCount();
        System.out.println(example.greet());

        String[] testItems = {"hello", "world", "", "mcp"};
        String[] processed = processItems(testItems);

        System.out.println("Processed items:");
        for (String item : processed) {
            System.out.println("- " + item);
        }
    }
}
