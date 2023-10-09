# Actions

Every service usually requires some configuration:

- settings that the user can modify in order to change the behavior of the service
- data that the service requires in order to do its work

Both those points require user input and logic bounded to the input. It is of great importance to facilitate the process of transforming the input to the logic bounded to the input. This is why we introduced actions. Actions are defined in markdown files and are then parsed by baobab. Baobab will know which action belongs to which actor based on its content and will initialize the actor with it. 

This allows the user to easily configure the service and allows the developer to easily extend the service with new behavior. Let's introduce the format in the next chapter. 

