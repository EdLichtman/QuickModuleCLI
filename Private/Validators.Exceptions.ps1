class ModuleProjectDoesNotExistException : Exception {
    ModuleProjectDoesNotExistException([String] $Message) : base($Message) {}
}

class ModuleProjectExistsException : Exception {
    ModuleProjectExistsException([String] $Message) : base($Message) {}
}

class ModuleExistsException : Exception {
    ModuleExistsException([String] $Message) : base($Message) {}
}

class CommandDoesNotExistException : Exception {
    CommandDoesNotExistException([String] $Message) : base($Message) {}
}
class ModuleCommandExistsException : Exception {
    ModuleCommandExistsException([String] $Message) : base($Message) {}
}

class ModuleCommandDoesNotExistException : Exception {
    ModuleCommandDoesNotExistException([String] $Message) : base($Message) {}
}

class ParameterStartsWithUnapprovedVerbException : Exception {
    ParameterStartsWithUnapprovedVerbException([String] $Message) : base($Message) {}
}

class ModuleProjectExportDestinationIsInvalidException : Exception {
    ModuleProjectExportDestinationIsInvalidException([String] $Message) : base($Message) {}
}

class ModuleCommandMoveDestinationIsInvalidException : Exception {
    ModuleCommandMoveDestinationIsInvalidException([String] $Message) : base($Message) {}
}

class ModuleProjectUnsupportedForImportException : ArgumentException {
    ModuleProjectUnsupportedForImportException([String] $Message) : base($Message) {}
}
