
This is a portfolio website for "Ary M Prayoga" built on the Statamic CMS and Laravel framework. The site is designed to showcase his blog posts, code snippets, projects, and work experience.

**Content Structure:**

*   **Blog:** Dated entries with a public status for past posts and a private status for future posts. The entries are sorted in descending order and use the `article` blueprint. They are organized with `tags` and `categories` taxonomies.
*   **Code Snippets:** Dated entries, publicly available, sorted in descending order, and using the `code_snippet` blueprint. They are categorized by `programming_languages`.
*   **Pages:** A hierarchical collection of pages, with the routing structure based on the parent-child relationship.
*   **Projects:** Dated entries, publicly available, sorted in descending order, and using the `project` blueprint.
*   **Work Experience:** Dated entries, publicly available, sorted in descending order, and using the `work_experience` blueprint.

**Technical Configuration:**

*   **Backend:** Laravel 12, PHP 8.2
*   **CMS:** Statamic 5
*   **Frontend:** Vite, Tailwind CSS, Alpine.js
*   **Testing:** PHPUnit
*   **APIs:** REST and GraphQL APIs are disabled.
*   **Git:** Git integration is disabled.
*   **Search:** Local search driver is used.
*   **Caching:** Static caching is disabled.
*   **Users:** Managed via files.
