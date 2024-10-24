# Employee Wiki

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@@picocss/pico@@2.0.6/css/pico.classless.min.css">

<form action="/update_employee" method="POST">

<label for="name">Name</label>
<input type="text" id="name" name="name" value="John Doe" required>

<label for="description">Description</label>
<textarea id="description" name="description" rows="3" required>Description of the employee</textarea>

<label for="department">Department</label>
<input type="text" id="department" name="department" value="HR" required>

<label for="cost">Cost</label>
<input type="number" id="cost" name="cost" value="10000" required>

<button type="submit" class="primary">Save Changes</button>

</form>
